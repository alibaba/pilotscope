import json
import logging
import uuid
from abc import ABC, abstractmethod
from copy import copy, deepcopy
from pathlib import Path
from string import Template

from prettytable import PrettyTable

# pylint: disable=import-error
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

LOG_FILENAME = 'log.txt'

class StorageInterface:
    def __init__(self, *args, **kwargs):
        self._outdir = "N/A"

    @property
    def outdir(self):
        return self._outdir

    @abstractmethod
    def store_knobs_importances(self, iter_, knob_importances):
        raise NotImplementedError

    @abstractmethod
    def store_executor_result(self, iter_, result):
        raise NotImplementedError

    @abstractmethod
    def store_result_summary(self, summary):
        raise NotImplementedError

class NoStorage(StorageInterface):
    def store_knobs_importances(self, iter_, knob_importances):
        pass

    def store_executor_result(self, iter_, result):
        pass

    def store_result_summary(self, summary):
        pass

class FileTablesStorage(StorageInterface):

    def __init__(self, outdir=None, columns=None, inner_path=None):
        assert outdir != None, 'Need to provide outdir'
        assert logger != None, 'Need to provide instance of logger'

        # Create base results dir if not exists
        outdir = Path(outdir) if not isinstance(outdir, Path) else outdir
        outdir.mkdir(exist_ok=True)

        if inner_path is None:
            # Create unique dir inside
            experiment_path = outdir / Path(uuid.uuid4().hex[:8])
            while experiment_path.exists():
                experiment_path = outdir / Path(uuid.uuid4().hex[:8])
        else:
            experiment_path = outdir / inner_path
            if experiment_path.exists():
                raise FileExistsError('Experiment output path already exists')
        experiment_path.mkdir(parents=True)
        self._outdir = experiment_path

        logger.addHandler(
            logging.FileHandler(self.outdir / LOG_FILENAME))
        logger.info(f'Results will be saved @ "{self.outdir}"\n\n')

        # Summary table initialization
        self.table = PrettyTable()
        self.table.field_names = copy(columns)
        self.table_txt_filepath = self.outdir / 'optimizer.txt'
        self.table_csv_filepath = self.outdir / 'optimizer.csv'
        self.executor_result_filename_template = Template('iter-${iter}.json')

    def store_knobs_importances(self, iter_, knob_importances):
        # Save to table
        ki_table = PrettyTable()
        ki_table.field_names = ['Knob', 'Importance Score']
        for knob, importance in knob_importances:
            logger.info(f'\t{knob}:\t{importance:.3f}')
            ki_table.add_row([knob, importance])

        ki_table_filepath = self.outdir / f'ki-{iter_}.txt'
        ki_table_csv_filepath = self.outdir / f'ki-{iter_}.csv'
        with open(ki_table_filepath, 'w') as f:
            f.write(ki_table.get_string())
        with open(ki_table_csv_filepath, 'w') as f:
            f.write(ki_table.get_csv_string())

        logger.info(f'Knobs importances saved @ {ki_table_filepath}')

    def store_executor_result(self, iter_, result):
        filename = self.executor_result_filename_template.substitute(iter=iter_)
        filepath = self.outdir / filename
        with open(filepath, 'w') as f:
            json.dump(result, f)

    def store_result_summary(self, summary):
        assert set(summary.keys()) == set(self.table.field_names)

        row = [ summary[k] for k in self.table.field_names ]
        self.table.add_row(row)

        with open(self.table_txt_filepath, 'w') as f:
            f.write(self.table.get_string())
        with open(self.table_csv_filepath, 'w') as f:
            f.write(self.table.get_csv_string())


class StorageFactory:
    concrete_classes = {
        'FileTablesStorage': FileTablesStorage,
        'NoStorage': NoStorage,
    }

    @staticmethod
    def from_config(config, **extra_kwargs):
        storage_config = deepcopy(config['storage'])

        classname = storage_config.pop('classname', None)
        assert classname != None, 'Please specify the storage class name'

        try:
            class_ = StorageFactory.concrete_classes[classname]
        except KeyError:
            raise ValueError(f'Storage class "{classname}" not found. '
            f'Options are [{", ".join(StorageFactory.concrete_classes.keys())}]')

        # Override with local
        storage_config.update(**extra_kwargs)

        return class_(**storage_config)
