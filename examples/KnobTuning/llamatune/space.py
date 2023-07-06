import json
from copy import deepcopy
from importlib import import_module
from pathlib import Path

import ConfigSpace as CS
import ConfigSpace.hyperparameters as CSH

from adapters import *

class ConfigSpaceGenerator:
    knob_types = ['enum', 'integer', 'real']
    valid_adapter_aliases = ['none', 'tree', 'rembo', 'hesbo']

    def __init__(self, definition=None, include=None, ignore=None, target_metric=None,
                    adapter_alias='none', le_low_dim=None, bias_prob_sv=None,
                    quantization_factor=None, finalize_conf_func=None, unfinalize_conf_func=None):
        if (ignore is not None) and (include is not None):
            raise ValueError("Define either `ignore_knobs' or `include_knobs'")
        assert isinstance(target_metric, str), 'Target metric should be of type string'
        assert adapter_alias in self.valid_adapter_aliases, \
            f"Valid values for `adapter_alias' are: {self.valid_adapter_aliases}"

        assert finalize_conf_func != None, 'Space should define "finalize_conf" function'
        self.finalize_conf_func = staticmethod(finalize_conf_func)
        assert unfinalize_conf_func != None, 'Space should define "unfinalize_conf" function'
        self.unfinalize_conf_func = staticmethod(unfinalize_conf_func)

        if bias_prob_sv is not None:
            bias_prob_sv = float(bias_prob_sv)
            assert 0 < bias_prob_sv < 1, 'Bias sampling prob should be in (0, 1) range'
        self._bias_prob_sv = bias_prob_sv

        if quantization_factor is not None:
            quantization_factor = int(quantization_factor)
            assert quantization_factor > 1, \
                'Quantization should be an integer value, larger than 1'
            assert (adapter_alias == 'none' and bias_prob_sv is None) or \
                    adapter_alias in ['rembo', 'hesbo']
        self._quantization_factor = quantization_factor

        all_knobs = set([ d['name'] for d in  definition ])
        include_knobs = include if include is not None else all_knobs - set(ignore)

        self.knobs = [ info for info in definition if info['name'] in include_knobs ]
        self.knobs_dict = { d['name']: d for d in self.knobs }

        self._target_metric = target_metric # to be used by the property
        self._adapter_alias = adapter_alias

        if adapter_alias in ['rembo', 'hesbo']:
            assert le_low_dim is not None, 'Linear embedding target dimensions not defined'
            self._le_low_dim = int(le_low_dim)
            assert self._le_low_dim < len(self.knobs), \
                'Linear embedding target dim should be less than original space'

    @property
    def target_metric(self):
        return self._target_metric

    def generate_input_space(self, seed: int, ignore_extra_knobs=None):
        ignore_extra_knobs = ignore_extra_knobs or [ ]

        input_dimensions = [ ]
        for info in self.knobs:
            name, knob_type = info['name'], info['type']
            if name in ignore_extra_knobs:
                continue

            if knob_type not in self.knob_types:
                raise NotImplementedError(f'Knob type of "{knob_type}" is not supported :(')

            ## Categorical
            if knob_type == 'enum':
                dim = CSH.CategoricalHyperparameter(
                        name=name,
                        choices=info['choices'],
                        default_value=info['default'])
            ## Numerical
            elif knob_type == 'integer':
                dim = CSH.UniformIntegerHyperparameter(
                        name=name,
                        lower=info['min'],
                        upper=info['max'],
                        default_value=info['default'])
            elif knob_type == 'real':
                dim = CSH.UniformFloatHyperparameter(
                        name=name,
                        lower=info['min'],
                        upper=info['max'],
                        default_value=info['default'])

            input_dimensions.append(dim)

        input_space = CS.ConfigurationSpace(name="input", seed=seed)
        input_space.add_hyperparameters(input_dimensions)

        if hasattr(self, 'input_space'):
            print('WARNING: Overriding input_space class variable')
        self.input_space = input_space

        self._input_space_adapter = None
        if self._adapter_alias == 'none':
            if self._bias_prob_sv is not None:
                # biased sampling
                self._input_space_adapter = PostgresBiasSampling(
                    input_space, seed, self._bias_prob_sv)
                return self._input_space_adapter.target

            if self._quantization_factor is not None:
                self._input_space_adapter = Quantization(
                    input_space, seed, self._quantization_factor)
                return self._input_space_adapter.target

            return input_space

        elif self._adapter_alias == 'tree':
            self._input_space_adapter = PostgresTreeConfigSpace(
                input_space, seed, bias_prob_sv=self._bias_prob_sv)
            return self._input_space_adapter.target

        else:
            assert self._adapter_alias in ['rembo', 'hesbo']

            if self._bias_prob_sv is not None:
                # biased sampling
                input_space = PostgresBiasSampling(
                    input_space, seed, self._bias_prob_sv).target

            self._input_space_adapter = LinearEmbeddingConfigSpace.create(
                input_space, seed,
                method=self._adapter_alias,
                target_dim=self._le_low_dim,
                bias_prob_sv=self._bias_prob_sv,
                max_num_values=self._quantization_factor)
            return self._input_space_adapter.target

    def get_default_configuration(self):
        return self.input_space.get_default_configuration()

    def finalize_conf(self, conf, n_decimals=2):
        return self.finalize_conf_func.__func__(
                conf, self.knobs_dict, n_decimals=n_decimals)

    def unfinalize_conf(self, conf):
        return self.unfinalize_conf_func.__func__(conf, self.knobs_dict)

    def unproject_input_point(self, point):
        if self._input_space_adapter:
            return self._input_space_adapter.unproject_point(point)
        return point


    @classmethod
    def from_config(cls, config):
        valid_config_fields = ['definition', 'include', 'ignore', 'target_metric',
                    'adapter_alias', 'le_low_dim', 'bias_prob_sv', 'quantization_factor']

        spaces_config = deepcopy(config['spaces'])
        assert all(field in valid_config_fields for field in spaces_config), \
            'Configuration contains invalid fields: ' \
            f'{set(spaces_config.keys()) - set(valid_config_fields)}'
        assert 'definition' in spaces_config, 'Spaces section should contain "definition" key'
        assert 'include' in spaces_config or 'ignore' in spaces_config, \
                    'Spaces section should contain "include" or "ignore" key'
        assert not ('include' in spaces_config and 'ignore' in spaces_config), \
                    'Spaces section should not contain both "include" and "ignore" keys'
        assert 'target_metric' in spaces_config, \
                    'Spaces section should contain "target_metric" key'
        if 'le_low_dim' in spaces_config:
            assert spaces_config['adapter_alias'] in ['rembo', 'hesbo'], \
                'Linear embedding low dimension is only valid in REMBO & HesBO'

        # Read space definition from json file
        definition_fp = Path('../examples/KnobTuning/llamatune/spaces/definitions') / f"{spaces_config['definition']}.json"
        with open(definition_fp, 'r') as f:
            definition = json.load(f)
        all_knobs_name = [ d['name'] for d in definition ]

        # Import designated module and utilize knobs
        include = 'include' in spaces_config
        module_name = spaces_config['include'] if include else spaces_config['ignore']
        import_path = module_name.replace('/', '.')
        module = import_module(f"spaces.{import_path}")
        knobs = getattr(module, 'KNOBS')
        assert isinstance(knobs, list) and all([ k in all_knobs_name for k in knobs])
        finalize_conf_func = getattr(module, 'finalize_conf')
        unfinalize_conf_func = getattr(module, 'unfinalize_conf')

        return cls(definition=definition,
            include=knobs if include else None,
            ignore=knobs if not include else None,
            target_metric=spaces_config['target_metric'],
            adapter_alias=spaces_config.get('adapter_alias', 'none'),
            le_low_dim=spaces_config.get('le_low_dim', None),
            bias_prob_sv=spaces_config.get('bias_prob_sv', None),
            quantization_factor=spaces_config.get('quantization_factor', None),
            finalize_conf_func=finalize_conf_func,
            unfinalize_conf_func=unfinalize_conf_func)
