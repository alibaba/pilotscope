from typing import Optional

import ConfigSpace as CS
import ConfigSpace.hyperparameters as CSH
import numpy as np
from sklearn.preprocessing import MinMaxScaler

import logging
logger = logging.getLogger(__name__)

class Quantization:
    def __init__(self,
            adaptee: CS.ConfigurationSpace, seed: int, max_num_values: int,
            ):

        self._adaptee: CS.ConfigurationSpace = adaptee
        self._target: CS.ConfigurationSpace = None
        self._seed: int = seed
        self._max_num_values: int = max_num_values
        assert max_num_values > 1

        self._rs = np.random.RandomState(seed=self._seed)

        self._build_space()

    def _build_space(self):
        self._knobs_scalers = { }

        root_hyperparams = [ ]
        for adaptee_hp in self.adaptee.get_hyperparameters():
            if not isinstance(adaptee_hp, CSH.UniformIntegerHyperparameter):
                # Leave float & categorical hps as is
                root_hyperparams.append(adaptee_hp)
                continue

            if not self._needs_quantization(adaptee_hp):
                # If values range <= max values, then leave as is
                root_hyperparams.append(adaptee_hp)
                continue

            # quantize knob
            lower, upper = adaptee_hp.lower, adaptee_hp.upper
            scaler = MinMaxScaler(feature_range=(lower, upper))
            scaler.fit([[1], [self._max_num_values]])
            self._knobs_scalers[adaptee_hp.name] = scaler

            default_value = round(
                scaler.inverse_transform([[ adaptee_hp.default_value ]])[0][0])
            quantized_hp = CSH.UniformIntegerHyperparameter(
                f'{adaptee_hp.name}|q', 1, self._max_num_values,
                default_value=default_value,
            )
            root_hyperparams.append(quantized_hp)

        root = CS.ConfigurationSpace(
            name=self._adaptee.name,
            seed=self._seed,
        )
        root.add_hyperparameters(root_hyperparams)
        self._target = root

    def _needs_quantization(self, hp):
        return (hp.upper - hp.lower + 1) > self._max_num_values

    @property
    def adaptee(self) -> CS.ConfigurationSpace:
        return self._adaptee

    @property
    def target(self) -> CS.ConfigurationSpace:
        return self._target

    def project_point(self, point):
        raise NotImplementedError()

    def unproject_point(self, point: CS.Configuration) -> dict:
        coords = point.get_dictionary()
        valid_dim_names = [ dim.name for dim in self.adaptee.get_hyperparameters() ]
        unproject_coords = { }
        for name, value in coords.items():
            dequantize = name.endswith('|q')
            if not dequantize:
                unproject_coords[name] = value
                continue

            # de-quantize
            dim_name = name[:-2]
            assert dim_name in valid_dim_names and dim_name in self._knobs_scalers

            scaler, value = self._knobs_scalers[dim_name], coords[name]
            lower, upper = scaler.feature_range
            # transform value
            value = int(scaler.transform([[ value ]])[0][0])
            value = max(lower, min(upper, value))
            unproject_coords[dim_name] = value

        return unproject_coords

    def project_dataframe(self, df, in_place: bool):
        raise NotImplementedError()

    def unproject_dataframe(self, df, in_place: bool):
        raise NotImplementedError()


