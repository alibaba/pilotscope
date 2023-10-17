import unittest

import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
from pandas import DataFrame

from utils import get_plt, name_2_color, capitalize, to_rgb_tuple, font_size, framework_name, \
    connect_framework_algo, pilot_scope_col_name, query_time_name

# fine-gained version with detailed cost of pilotscope

class MyTestCase(unittest.TestCase):
    def setUp(self):
        self.x = ["Knob Tuning", "Index Recommendation", "Cardinality Estimation", "Query Optimizer"]
        self.db = "PostgreSQL"
        self.query_time_name = query_time_name
        self.left_x = [self.query_time_name, connect_framework_algo(self.db), self.db]
        self.scale_ratio = 1.05
        self.min_ratio = 0.01

    def test_drawLegend(self):
        names = [self.query_time_name, connect_framework_algo(self.db), self.db,
                 "Push Hint", "Pull Plan", "ML_Method", "Http", "Storage", pilot_scope_col_name, "Push Index",
                 "Push Knob",
                 "Push Subquery", "Pull Subquery"]
        colors = [name_2_color[n.lower()] for n in names]
        hatches = [""] * 3 + ["/"] * (len(names) - 3)
        file_name = "performance_legend"
        self.colors2legend_bar(colors, names, hatches, file_name)

    def test_qo_stats(self):
        db = "stats"
        algo = "bao"
        left_values = [19999, 29224, 29224]
        right_x = ["Push Hint", "Pull Plan", "ML_Method", "Http", "Storage"]
        right_values = [1.31, 2.5, 8.7, 0.35, 0.37]
        pilot_time = left_values[0] * self.scale_ratio
        self.draw_bar_chart(self.left_x, left_values, right_x, right_values, pilot_time, "{}_{}".format(algo, db))

    def test_index_stats(self):
        db = "stats"
        algo = "extend"
        left_values = [16006, 29224, 29224]
        right_x = {"Push Index", "Http"}
        right_values = [0.000025, 0.003]
        pilot_time = left_values[0] * self.scale_ratio
        self.draw_bar_chart(self.left_x, left_values, right_x, right_values, pilot_time, "{}_{}".format(algo, db))

    def test_knob_stats(self):
        db = "stats"
        algo = "smac"
        left_values = [10756, 29224, 29224]
        right_x = ["Push Knob", "Http"]
        right_values = [1.43, 0.003]
        pilot_time = left_values[0] * self.scale_ratio
        self.draw_bar_chart(self.left_x, left_values, right_x, right_values, pilot_time, "{}_{}".format(algo, db))

    def test_card_stats(self):
        db = "stats"
        algo = "deepdb"
        left_values = [21952, 29224, 29224]
        right_x = ["Push Subquery", "Pull Subquery", "ML_Method", "Http", "Storage"]
        right_values = [0.065, 0.099, 75.43, 1.101, 0.36]
        pilot_time = left_values[0] * self.scale_ratio
        self.draw_bar_chart(self.left_x, left_values, right_x, right_values, pilot_time, "{}_{}".format(algo, db))

    def test_qo_imdb(self):
        db = "imdb"
        algo = "bao"
        left_values = [541, 550, 550]
        right_x = ["Push Hint", "Pull Plan", "ML_Method", "Http", "Storage"]
        right_values = [2.65, 103, 56, 1.06, 0.37]
        pilot_time = 628
        self.draw_bar_chart(self.left_x, left_values, right_x, right_values, pilot_time, "{}_{}".format(algo, db))

    def test_index_imdb(self):
        db = "imdb"
        algo = "extend"
        left_values = [512, 550, 550]
        right_x = {"Push Index", "Http"}
        right_values = [0.38, 1.6]
        pilot_time = left_values[0] * self.scale_ratio
        self.draw_bar_chart(self.left_x, left_values, right_x, right_values, pilot_time, "{}_{}".format(algo, db))

    def test_knob_imdb(self):
        db = "imdb"
        algo = "smac"
        left_values = [331, 550, 550]
        right_x = ["Push Knob", "Http"]
        right_values = [1.48, 0.03]
        pilot_time = left_values[0] * self.scale_ratio
        self.draw_bar_chart(self.left_x, left_values, right_x, right_values, pilot_time, "{}_{}".format(algo, db))

    def test_card_imdb(self):
        db = "imdb"
        algo = "deepdb"
        left_values = [4847, 5458, 5458]
        right_x = ["Push Subquery", "Pull Subquery", "ML_Method", "Http", "Storage"]
        right_values = [0.009, 0.02, 6.23, 0.26, 0.03]
        pilot_time = left_values[0] * self.scale_ratio
        self.draw_bar_chart(self.left_x, left_values, right_x, right_values, pilot_time, "{}_{}".format(algo, db))

    def get_fig_name(self, algo, db):
        return "{}_{}".format(algo, db)

    # read xlsx file by dataframe of pandas
    def read_data(self, algo, db):
        file_path = "Experiment/Data/{}_{}.xlsx".format(algo, db)
        df: DataFrame = pd.read_excel(file_path, header=0)

        # get sum value
        value = df.iloc[0, :]
        return list(df.columns), list(value)

    def draw_bar_chart(self, left_x, left_values: list, right_x, right_values: list, end_to_end_time, file,
                       bar_width=0.12):
        gap = 0.5
        y_label = "Total Time(s)"
        fig, ax = plt.subplots()
        # fig.figure(figsize=(12, 10))

        # 绘制前四个bar，使用左边的坐标轴
        colors = [name_2_color[name.lower()] for name in left_x]
        colors = [to_rgb_tuple(color) for color in colors]
        x = list(range(0, len(left_x)))
        # 添加pilot 的时间作为堆叠
        ax.bar(x[0:1], end_to_end_time, color=to_rgb_tuple(name_2_color[pilot_scope_col_name.lower()]))
        ax.bar(x, left_values, color=colors)
        # ax.bar([1, 2, 3, 4], data_left_stacked, color='g', bottom=data_left)
        ax.set_ylabel(y_label)

        # 创建第二个坐标轴对象
        ax2 = ax.twinx()
        max_value = max(right_values)
        right_values = [max_value * self.min_ratio if v < max_value * self.min_ratio else v for v in right_values]
        # 绘制后两个bar，使用右边的坐标轴
        colors = [name_2_color[name.lower()] for name in right_x]
        colors = [to_rgb_tuple(color) for color in colors]
        start = len(x)
        x2 = list(range(start, start + len(right_x)))
        x2 = [gap + v for v in x2]
        ax2.bar(x2, right_values, color=colors, hatch="/")
        ax2.set_ylabel(y_label)

        ax.tick_params(axis='x', bottom=False)

        ax.axvline(x=(x[-1] + x2[0]) / 2, color='black', linestyle='--')

        ax.set_xticks([])
        ax2.set_xticks([])

        plt.grid(axis='y', linestyle='--')
        plt.tight_layout()
        plt.savefig('../Fig/{}.pdf'.format(file), format='pdf')
        plt.show()

    def colors2legend_bar(self, colors, names, hatches, file_name, handletextpad=1.0, columnspacing=1.0,
                          handlelength=1.0):
        # 创建一个空白的图形
        fig = plt.figure(figsize=(110, 5))

        # 添加需要的图例
        for i in range(len(colors)):
            hatch = "" if hatches is None else hatches[i]
            plt.bar([0], [0], label=names[i], hatch=hatch, color=to_rgb_tuple(colors[i]))
            # plt.bar([0], [0], label=names[i], color=to_rgb_tuple(colors[i]))

        # ax.legend(loc='upper center', bbox_to_anchor=(0.5, 1.15), ncol=len(colors), facecolor='gray', edgecolor='black')
        legend = plt.legend(loc='upper center', bbox_to_anchor=(0.5, 0.9), ncol=len(colors), fontsize=font_size + 10,
                            handletextpad=handletextpad, columnspacing=columnspacing, handlelength=handlelength)

        plt.gca().spines['top'].set_visible(False)
        plt.gca().spines['right'].set_visible(False)
        plt.gca().spines['bottom'].set_visible(False)
        plt.gca().spines['left'].set_visible(False)
        plt.axis('off')
        legend_margin_width = 5
        legend.get_frame().set_linewidth(legend_margin_width)
        # width = 15
        # for i in range(len(colors)):
        #     legend.get_lines()[i].set_linewidth(width)
        #     legend.legendHandles[i].set_linestyle(lines[i])
        plt.show()
        pdf = PdfPages('../Fig/{}.pdf'.format(file_name))
        pdf.savefig(fig)
        # plt.savefig('draw_fig/{}.pdf'.format(file_name))
        pdf.close()


if __name__ == '__main__':
    unittest.main()
