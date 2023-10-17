import bisect
import unittest

import math
import pandas as pd
from matplotlib import pyplot as plt
import matplotlib as mpl
import matplotlib.patches as mpatches

from test_example_algorithms.Experiment.Code.drawBaoComparePerf import DrawBaoComparePerf
from test_example_algorithms.Experiment.Code.utils import font_size


class DrawCompareCard(DrawBaoComparePerf):
    def test_stats(self):
        db = "stats"
        self.compare_performance(db)

    def test_imdb(self):
        db = "joblight"
        self.compare_performance(db)

    # def compare_performance(self, db):
    #     df = self.read_data(db)
    #     trueCard_data = list(df["trueCard"])
    #     pg_data = list(df["pg"])
    #     deepdb_data = list(df["deepdb"])
    #
    #     pg_q_error = [self.cal_q_error(pg_data[i], trueCard_data[i]) for i in range(len(trueCard_data))]
    #     deepdb_q_error = [self.cal_q_error(deepdb_data[i], trueCard_data[i]) for i in range(len(trueCard_data))]
    #
    #     pg_q_error = [math.log(e) for e in pg_q_error]
    #     deepdb_q_error = [math.log(e) for e in deepdb_q_error]
    #     # self.draw_line(deepdb_q_error, pg_q_error, "{}_card_compare_performance".format(db))
    #
    #     data = [deepdb_q_error[i] - pg_q_error[i] for i in range(len(pg_q_error))]
    #     data = sorted(data)
    #
    #     self.draw_bar(data, "{}_card_compare_performance".format(db), y_label="Q-Error (Log)",
    #                   legends=["LargerError", "SmallerError"])

    # def compare_performance(self, db):
    #     df = self.read_data(db)
    #     trueCard_data = list(df["trueCard"])
    #     pg_data = list(df["pg"])
    #     deepdb_data = list(df["deepdb"])
    #
    #     combs = list(zip(trueCard_data, pg_data, deepdb_data))
    #     combs.sort(key=lambda a: a[0])
    #     trueCard_data, pg_data, deepdb_data = zip(*combs)
    #
    #     pg_q_error = [self.cal_q_error(pg_data[i], trueCard_data[i]) for i in range(len(trueCard_data))]
    #     deepdb_q_error = [self.cal_q_error(deepdb_data[i], trueCard_data[i]) for i in range(len(trueCard_data))]
    #
    #     pg_q_error = [math.log(e) for e in pg_q_error]
    #     deepdb_q_error = [math.log(e) for e in deepdb_q_error]
    #     # self.draw_line(deepdb_q_error, pg_q_error, "{}_card_compare_performance".format(db))
    #
    #     data = [deepdb_q_error[i] - pg_q_error[i] for i in range(len(pg_q_error))]
    #     # data = sorted(data)
    #
    #     self.draw_bar(data, "{}_card_compare_performance".format(db), y_label="Q-Error (Log)",
    #                   legends=["LargerError", "SmallerError"])

    def compare_performance(self, db):
        df = self.read_data(db)
        trueCard_data = list(df["trueCard"])
        pg_data = list(df["pg"])
        deepdb_data = list(df["deepdb"])

        combs = list(zip(trueCard_data, pg_data, deepdb_data))
        combs.sort(key=lambda a: a[0])
        trueCard_data, pg_data, deepdb_data = zip(*combs)

        pg_q_error = [self.cal_q_error(pg_data[i], trueCard_data[i]) for i in range(len(trueCard_data))]
        deepdb_q_error = [self.cal_q_error(deepdb_data[i], trueCard_data[i]) for i in range(len(trueCard_data))]
        deepdb_q_error = [math.log(e) for e in deepdb_q_error]
        # x = [0, 10, 100, 1000, 10000, 10000]
        if db == "joblight":
            x = [5000, 50000, ]
        elif db == "stats":
            # x = [ 1000, 10000]
            x = [5000, 50000, ]
        else:
            raise RuntimeError

        values_list = [[] for _ in range(len(x) + 1)]
        cards_list = [[] for _ in range(len(x) + 1)]

        for i in range(len(trueCard_data)):
            card = trueCard_data[i]
            q_error = deepdb_q_error[i]
            pos = bisect.bisect_left(x, card)
            values_list[pos].append(q_error)
            cards_list[pos].append(card)

        if db == "joblight":
            x_labels = ["<5000", "<50000", "Remain"]
        elif db == "stats":
            x_labels = ["<5000", "<50000", "Remain"]
        self.draw_box(x_labels, values_list, "{}_card_compare_performance".format(db))

    def draw_box(self, x, values, file_name):
        mpl.rcParams['font.size'] = font_size - 5
        plt.boxplot(values, labels=x)
        plt.xlabel('True Cardinality')
        plt.ylabel('Q-error')
        plt.tight_layout()
        plt.savefig('../Fig/{}.pdf'.format(file_name))
        plt.show()

    def draw_line(self, line1, line2, file_name):
        x = [i for i in range(len(line1))]
        plt.scatter(x, line1, color='red', label='DeepDb')
        if line2 is not None:
            plt.scatter(x, line2, color='green', label='PostgreSQL')
        plt.xlabel('The i-th SQL Query')
        plt.ylabel('Q-Error')
        plt.legend()
        plt.savefig('../Fig/{}.pdf'.format(file_name))
        plt.show()

    def read_data(self, db):
        return pd.read_excel("../Data/DeepDB_PG_Card_compare.xlsx",
                             sheet_name=0 if db == "joblight" else 1)

    def cal_q_error(self, a, b):
        return float(max(a, b)) / min(a, b)


if __name__ == '__main__':
    unittest.main()
