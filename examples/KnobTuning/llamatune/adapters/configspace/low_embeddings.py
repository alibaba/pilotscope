from abc import ABC, abstractmethod
from typing import Optional

import ConfigSpace as CS
import ConfigSpace.hyperparameters as CSH
import numpy as np
from sklearn.preprocessing import MinMaxScaler

from adapters.bias_sampling import UniformIntegerHyperparameterWithSpecialValue, special_value_scaler

import logging
logger = logging.getLogger(__name__)

class LinearEmbeddingConfigSpace(ABC):
    def __init__(self,
            adaptee: CS.ConfigurationSpace, seed: int, target_dim: int,
            bias_prob_sv: Optional[float] = None, # biased-sampling
            max_num_values: Optional[int] = None, # quantization
            ):

        self._adaptee: CS.ConfigurationSpace = adaptee
        self._target: CS.ConfigurationSpace = None
        self._seed: int = seed
        self._target_dim: int = target_dim
        self._bias_prob_sv: Optional[float] = bias_prob_sv
        self._max_num_values: Optional[int] = max_num_values

        self._rs = np.random.RandomState(seed=self._seed)

        self._build_space()

    @abstractmethod
    def _build_space(self):
        raise NotImplementedError()

    def _get_active_hps(self):
        # NOTE: add multi-choice categorical vars
        return self.adaptee.get_hyperparameters()

    @property
    def adaptee(self) -> CS.ConfigurationSpace:
        return self._adaptee

    @property
    def target(self) -> CS.ConfigurationSpace:
        return self._target

    def project_point(self, point):
        raise NotImplementedError()

    @abstractmethod
    def unproject_point(self, point:CS.Configuration) -> dict:
        raise NotImplementedError()

    def project_dataframe(self, df, in_place: bool):
        raise NotImplementedError()

    def unproject_dataframe(self, df, in_place: bool):
        raise NotImplementedError()

    @staticmethod
    def create(*args, method: str = 'hesbo', **kwargs):
        if method not in ['hesbo', 'rembo']:
            raise ValueError("Supported methods are 'rembo', 'hesbo'")

        if method == 'rembo':
            return REMBOConfigSpace(*args, **kwargs)
        elif method == 'hesbo':
            return HesBOConfigSpace(*args, **kwargs)
        else:
            raise NotImplementedError()


class REMBOConfigSpace(LinearEmbeddingConfigSpace):

    def _build_space(self):
        self.active_hps = self._get_active_hps()

        # Create lower dimensionality configuration space
        # NOTE: space bounds are [-sqrt(low_dim), sqrt(low_dim)] rather than [-1, 1]
        box_bound = np.sqrt(self._target_dim)
        target = CS.ConfigurationSpace(
            name=self._adaptee.name, seed=self._seed)

        if self._max_num_values is None:
            hps = [
                CS.UniformFloatHyperparameter(
                    name=f'rembo_{idx}', lower=-box_bound, upper=box_bound)
                for idx in range(self._target_dim)
            ]
            q_scaler = None
        else:
            logger.info(f'Using quantization: q={self._max_num_values}')
            hps = [
                CS.UniformIntegerHyperparameter(
                    name=f'rembo_{idx}', lower=1, upper=self._max_num_values)
                for idx in range(self._target_dim)
            ]
            # (1, q) -> (-sqrt(low_dim), sqrt(low_dim)) scaling
            q_scaler = MinMaxScaler(feature_range=(-box_bound, box_bound))
            ones = np.ones(shape=self._target_dim)
            q_scaler.fit([ones, ones * self._max_num_values])

        target.add_hyperparameters(hps)
        logger.info(target)

        self._target = target
        self._q_scaler = q_scaler

        # (-sqrt, sqrt) -> (0, 1) scaling
        self._scaler = MinMaxScaler(feature_range=(0, 1))
        bbound_vector = np.ones(len(self.active_hps)) * box_bound
        # use two points (minimum & maximum)
        self._scaler.fit(
            np.array([-bbound_vector, bbound_vector]))

        # Create random project matrix: A ~ N(0,1)
        self._A = self._rs.normal(
            0, 1, (len(self.active_hps), self._target_dim))

    def unproject_point(self, point: CS.Configuration) -> dict:
        low_dim_point = np.array([
            point.get(f'rembo_{idx}') for idx in range(len(point)) ])

        if self._max_num_values is not None:
            assert self._q_scaler is not None # self-validate
            low_dim_point = self._q_scaler.transform([low_dim_point])[0]

        high_dim_point = [
            np.dot(self._A[idx, :], low_dim_point)
            for idx in range(len(self.active_hps))
        ]
        high_dim_point = self._scaler.transform([high_dim_point])[0]

        high_dim_conf = { }
        dims_clipped = 0
        for hp, value in zip(self.active_hps, high_dim_point):
            if value <= 0 or value >= 1:
                logger.warning('Point clipped in dim: %s' % hp.name)
                dims_clipped += 1
            # clip value to [0, 1]
            value = np.clip(value, 0., 1.)

            if isinstance(hp, CS.CategoricalHyperparameter):
                index = int(value * len(hp.choices)) # truncate integer part
                index = max(0, min(len(hp.choices) - 1, index))
                # NOTE: rounding here would be unfair to first & last values
                value = hp.choices[index]
            elif isinstance(hp, CS.hyperparameters.NumericalHyperparameter):
                if isinstance(hp, UniformIntegerHyperparameterWithSpecialValue):
                    value = special_value_scaler(hp, value) # bias special value

                value = hp._transform(value)
                value = max(hp.lower, min(hp.upper, value))
                assert value >= hp.lower and value <= hp.upper
            else:
                raise NotImplementedError()

            high_dim_conf[hp.name] = value

        if dims_clipped > 0:
            logger.info('# dimensions clipped: %d' % dims_clipped)

        return high_dim_conf


class HesBOConfigSpace(LinearEmbeddingConfigSpace):

    def _build_space(self):
        self.active_hps = self._get_active_hps()

        # Create lower dimensionality configuration space
        target = CS.ConfigurationSpace(
            name=self._adaptee.name, seed=self._seed)

        if self._max_num_values is None:
            hps = [
                CS.UniformFloatHyperparameter(
                    name=f'hesbo_{idx}', lower=-1, upper=1)
                for idx in range(self._target_dim)
            ]
        else:
            logger.info(f'Using quantization: q={self._max_num_values}')
            q = 2. / self._max_num_values
            hps = [
                CS.UniformFloatHyperparameter(
                    name=f'hesbo_{idx}', lower=-1, upper=1, q=q)
                for idx in range(self._target_dim)
            ]

        target.add_hyperparameters(hps)
        logger.info(target)

        self._target = target

        # (-1, 1) -> (0, 1) scaling
        self._scaler = MinMaxScaler(feature_range=(0, 1))
        ones = np.ones(len(self.active_hps))
        # use two points (minimum & maximum)
        self._scaler.fit(
            np.array([-ones, ones]))

        # Implicitely define matrix S'
        self._h = self._rs.choice(
            range(self._target_dim), len(self.active_hps))
        self._sigma = self._rs.choice([-1, 1], len(self.active_hps))

    def unproject_point(self, point: CS.Configuration) -> dict:
        low_dim_point = [
            point.get(f'hesbo_{idx}') for idx in range(len(point)) ]

        # OLD METHOD OF QUANTIZATION
        #if self._max_num_values is not None and self.q_use_integer:
        #    assert self._q_scaler is not None # self-validate
        #    low_dim_point = self._q_scaler.transform([low_dim_point])[0]

        high_dim_point = [
            self._sigma[idx] * low_dim_point[self._h[idx]]
            for idx in range(len(self.active_hps))
        ]
        high_dim_point = self._scaler.transform([high_dim_point])[0]

        high_dim_conf = { }
        for hp, value in zip(self.active_hps, high_dim_point):
            # hesbo does not project values outside of range
            # NOTE: need this cause of weird floating point errors
            value = max(0, min(1, value))

            if isinstance(hp, CS.CategoricalHyperparameter):
                index = int(value * len(hp.choices)) # truncate integer part
                index = max(0, min(len(hp.choices) - 1, index))
                # NOTE: rounding here would be unfair to first & last values
                value = hp.choices[index]
            elif isinstance(hp, CS.hyperparameters.NumericalHyperparameter):
                if isinstance(hp, UniformIntegerHyperparameterWithSpecialValue):
                    value = special_value_scaler(hp, value) # bias special value

                value = hp._transform(value)
                value = max(hp.lower, min(hp.upper, value))
                assert value >= hp.lower and value <= hp.upper
            else:
                raise NotImplementedError()

            high_dim_conf[hp.name] = value

        return high_dim_conf
