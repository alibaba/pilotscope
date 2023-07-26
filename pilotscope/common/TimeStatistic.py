import time
from threading import current_thread, Lock

from pandas import DataFrame


class TimeStatistic:
    _start_time = {}
    _count = {}
    _total_time = {}
    _lock = Lock()

    @classmethod
    def start(cls, name):
        with cls._lock:
            thread_id = current_thread().ident
            cls._start_time[(thread_id, name)] = time.time()

    @classmethod
    def end(cls, name):
        with cls._lock:
            thread_id = current_thread().ident
            if (thread_id, name) in cls._start_time:
                inc_time = time.time() - cls._start_time[(thread_id, name)]
                cls._add_time(name, inc_time)
                del cls._start_time[(thread_id, name)]
            else:
                raise RuntimeError("end but no start")

    @classmethod
    def _add_time(cls, name, inc_time):
        if name not in cls._total_time:
            cls._total_time[name] = 0
            cls._count[name] = 0
        cls._total_time[name] += inc_time
        cls._count[name] += 1

    @classmethod
    def add_time(cls, name, inc_time):
        with cls._lock:
            cls._add_time(name, inc_time)

    @classmethod
    def report(cls):
        data = {
            'name': [],
            'count': [],
            'total_time': [],
            'average_time': []
        }
        for name in cls._total_time:
            data['name'].append(name)
            data['count'].append(cls._count[name])
            data['total_time'].append(cls._total_time[name])
            data['average_time'].append(cls._total_time[name] / cls._count[name])
        return DataFrame(data)

    @classmethod
    def save_xlsx(cls, file_path):
        res = {}
        for name in cls._total_time.keys():
            total = cls._total_time[name]
            count = cls._count[name]
            aver = total / count
            res[name] = [total, aver, count]

        df = DataFrame(res)
        df.to_excel(file_path)

    @classmethod
    def get_average_data(cls):
        name_2_values = {}
        for name in cls._total_time.keys():
            total = cls._total_time[name]
            count = cls._count[name]
            aver = total / count
            name_2_values[name] = aver
        return name_2_values

    @classmethod
    def get_sum_data(cls):
        name_2_values = {}
        for name in cls._total_time.keys():
            total = cls._total_time[name]
            name_2_values[name] = total
        return name_2_values

    @classmethod
    def get_count_data(cls):
        name_2_values = {}
        for name in cls._total_time.keys():
            name_2_values[name] = cls._count[name]
        return name_2_values
