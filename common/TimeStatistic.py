import os
import time

from pandas import DataFrame


class TimeStatistic:
    _start_time = {}
    _count = {}
    _total_time = {}

    @classmethod
    def start(cls, name):
        cls._start_time[name] = time.time()

    @classmethod
    def end(cls, name):
        if name in cls._start_time:
            inc_time = time.time() - cls._start_time[name]
            cls.add_time(name, inc_time)
        else:
            raise RuntimeError("end but no start")

    @classmethod
    def add_time(cls, name, inc_time):
        if name in cls._count:
            cls._count[name] = cls._count[name] + 1
            cls._total_time[name] = cls._total_time[name] + inc_time
        else:
            cls._count[name] = 1
            cls._total_time[name] = inc_time

    @classmethod
    def print(cls):
        names = list(cls._total_time.keys())
        print("############################")
        for name in names:
            total = cls._total_time[name]
            count = cls._count[name]
            aver = total / count
            print("{}: total time is {}, aver time is {}, count  is {}".format(name, total, aver, count))
        print("############################")

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
