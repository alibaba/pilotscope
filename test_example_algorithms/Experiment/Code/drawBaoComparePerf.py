import unittest
import pandas as pd
from matplotlib import pyplot as plt
import matplotlib as mpl
import matplotlib.patches as mpatches

from test_example_algorithms.Experiment.Code.utils import font_size


class DrawBaoComparePerf(unittest.TestCase):
    def test_stats(self):
        db = "stats"
        self.compare_performance(db)

    def test_imdb(self):
        db = "imdb"
        self.compare_performance(db)

    def compare_performance(self, db):
        df = self.read_data(db)
        bao_data = list(df["bao"])
        pg_data = list(df["pg"])
        data = [bao_data[i] - pg_data[i] for i in range(len(bao_data))]
        data = sorted(data)
        data = [v for v in data if abs(v) >= 1]

        self.draw_bar(data, "{}_bao_compare_performance".format(db))

    def draw_bar(self, data, file_name, x_label="The i-th SQL Query", y_label="Plan Execution Time (s)",
                 legends=["Speedup", 'Slowdown']):
        mpl.rcParams['font.size'] = font_size - 5
        colors = ['red' if x > 0 else 'green' for x in data]  # 根据值判断颜色
        plt.bar(range(len(data)), data, color=colors)
        plt.ylabel(y_label, fontsize=font_size)
        plt.xlabel(x_label, fontsize=font_size)
        plt.grid(axis='y', linestyle='--')
        red_patch = mpatches.Patch(color='red', label=legends[0])
        green_patch = mpatches.Patch(color='green', label=legends[1])
        plt.legend(handles=[red_patch, green_patch])
        plt.tight_layout()
        plt.savefig('../Fig/{}.pdf'.format(file_name))
        plt.show()

    def read_data(self, db):
        return pd.read_excel("../Data/{}full_plan_compare.xlsx".format(db))


if __name__ == '__main__':
    unittest.main()
