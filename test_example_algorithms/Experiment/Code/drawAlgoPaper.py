import unittest

import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
from pandas import DataFrame

from utils import get_plt, name_2_color, capitalize, to_rgb_tuple, font_size, framework_name, \
    connect_framework_algo, pilot_scope_col_name, query_time_name, right_bar_names, db_algo_names


class MyTestCase(unittest.TestCase):
    def setUp(self):
        self.x = ["Knob Tuning", "Index Recommendation", "Cardinality Estimation", "Query Optimizer"]
        self.r_x = right_bar_names
        self.db = "PostgreSQL"
        self.query_time_name = query_time_name
        self.left_x = [self.query_time_name, connect_framework_algo(self.db), self.db]
        self.scale_ratio = 1.05
        self.min_ratio = 0.01

    # def test_drawLegend(self):
    #     names = [db_algo_names[0],
    #              right_bar_names[0],
    #              db_algo_names[1],
    #              right_bar_names[1],
    #              db_algo_names[2],
    #              right_bar_names[2],
    #              " ",
    #              right_bar_names[3]]
    #     colors = [name_2_color[n.lower()] for n in names]
    #     hatches = ["", "/", "", "/", "", "/", "", "/"]
    #     file_name = "performance_legend"
    #     self.colors2legend_bar(colors, names, hatches, file_name)

    def test_drawLegend(self):
        names = [db_algo_names[0],
                 db_algo_names[8],
                 right_bar_names[0],
                 db_algo_names[1],
                 db_algo_names[9],
                 right_bar_names[1],
                 db_algo_names[2],
                 db_algo_names[10],
                 right_bar_names[2],
                 " ",
                 " ",
                 right_bar_names[3]]
        colors = [name_2_color[n.lower()] for n in names]
        hatches = ["", "o", "/", "", "o", "/", "", "o", "/", "", "", "/"]
        file_name = "performance_legend"
        self.colors2legend_bar(colors, names, hatches, file_name,ncol=4)

    def test_drawLegend_spark(self):
        names = [db_algo_names[8],
                 db_algo_names[9],
                 right_bar_names[0],
                 right_bar_names[2],
                 db_algo_names[10],
                 " ",
                 right_bar_names[1],
                 right_bar_names[3]]
        colors = [name_2_color[n.lower()] for n in names]
        hatches = ["", "", "/", "/", "", "", "/", "/"]
        file_name = "spark_performance_legend"
        self.colors2legend_bar(colors, names, hatches, file_name, ncol=2)

    def test_drawLegend_mixed(self):
        names = [db_algo_names[3],
                 db_algo_names[7],
                 db_algo_names[4],
                 db_algo_names[5],
                 db_algo_names[6],
                 db_algo_names[1],
                 db_algo_names[11],
                 ]
        colors = [name_2_color[n.lower()] for n in names]
        hatches = ["", "", "", "", "", "", ""]
        file_name = "mixed_performance_legend"
        self.colors2legend_bar(colors, names, hatches, file_name, ncol=4)

    def test_drawLegend_mixed_revision(self):
        names = [
            db_algo_names[11],
            db_algo_names[5],
            db_algo_names[6],
            db_algo_names[1],
        ]
        colors = [name_2_color[n.lower()] for n in names]
        hatches = ["", "", "", "", ]
        file_name = "mixed_performance_legend_revision"
        self.colors2legend_bar(colors, names, hatches, file_name, ncol=2)

    def test_qo_stats(self):
        db = "stats"
        algo = "bao"
        left_values = [20010, 29224, 29224]
        right_values = [2.5, 1.31, 0.35, 0.37]
        self.draw_bar_chart(self.left_x, left_values, self.r_x, right_values, "{}_{}".format(algo, db),
                            left_y_max=30000)

    def test_index_stats(self):
        db = "stats"
        algo = "extend"
        left_values = [16007, 29224, 29224]
        right_values = [0, 0.000025, 0.003, 0]
        self.draw_bar_chart(self.left_x, left_values, self.r_x, right_values, "{}_{}".format(algo, db),
                            left_y_max=30000)

    def test_knob_stats(self):
        db = "stats"
        algo = "smac"
        left_values = [10758, 29224, 29224]
        right_values = [0, 1.43, 0.003, 0]
        self.draw_bar_chart(self.left_x, left_values, self.r_x, right_values, "{}_{}".format(algo, db),
                            left_y_max=30000)

    def test_card_stats(self):
        db = "stats"
        algo = "deepdb"
        left_values = [22035, 29224, 29224]
        right_values = [0.099, 0.065, 1.101, 0.36]
        self.draw_bar_chart(self.left_x, left_values, self.r_x, right_values, "{}_{}".format(algo, db),
                            left_y_max=30000)

    def test_qo_imdb(self):
        db = "imdb"
        algo = "bao"
        left_values = [628, 550, 550]
        right_values = [31.5, 2.65, 1.06, 0.37]
        self.draw_bar_chart(self.left_x, left_values, self.r_x, right_values, "{}_{}".format(algo, db),
                            left_y_max=650)

    def test_index_imdb(self):
        db = "imdb"
        algo = "extend"
        left_values = [532, 550, 550]
        right_values = [0, 0.38, 0.016, 0]
        self.draw_bar_chart(self.left_x, left_values, self.r_x, right_values, "{}_{}".format(algo, db),
                            left_y_max=650)

    def test_knob_imdb(self):
        db = "imdb"
        algo = "smac"
        left_values = [339, 550, 550]
        right_values = [0, 1.48, 0.03, 0]
        self.draw_bar_chart(self.left_x, left_values, self.r_x, right_values, "{}_{}".format(algo, db),
                            left_y_max=650)

    def test_card_imdb(self):
        db = "imdb"
        algo = "deepdb"
        left_values = [4854, 5458, 5458]
        right_values = [0.02, 0.009, 0.26, 0.03]
        self.draw_bar_chart(self.left_x, left_values, self.r_x, right_values, "{}_{}".format(algo, db))

    def test_qo_tpcds(self):
        db = "tpcds"
        algo = "bao"
        self.left_x[0] = db_algo_names[8]
        left_values = [752, 261, 261]
        right_values = [73, 325, 12, 86]
        self.draw_bar_chart(self.left_x, left_values, self.r_x, right_values, "{}_{}".format(algo, db),
                            left_y_max=800, enable_left_hatch=True)

    def test_knob_tpcds(self):
        db = "tpcds"
        algo = "smac"
        self.left_x[0] = db_algo_names[8]
        left_values = [411, 261, 261]
        right_values = [0, 0.22, 0.0023, 0]
        self.draw_bar_chart(self.left_x, left_values, self.r_x, right_values, "{}_{}".format(algo, db), left_y_max=800,
                            enable_left_hatch=True)

    def test_qo_knob_stats_no_overhead(self):
        db = "stats"
        algo = "bao_smac_no_overhead"
        x = [db_algo_names[3],
             db_algo_names[4],
             db_algo_names[6],
             db_algo_names[1]]
        left_values = [11484, 20010, 10758, 29224]
        self.draw_bar_chart(x, left_values, [], [], "{}_{}".format(algo, db),
                            left_y_max=30000, enable_right=False)

    def test_qo_card_stats_no_overhead(self):
        db = "stats"
        algo = "bao_deepdb_no_overhead"
        x = [db_algo_names[7],
             db_algo_names[4],
             db_algo_names[5],
             db_algo_names[1]]
        left_values = [23228, 20010, 22035, 29224]
        self.draw_bar_chart(x, left_values, [], [], "{}_{}".format(algo, db),
                            left_y_max=30000, enable_right=False)

    def test_knob_card_stats_no_overhead(self):
        db = "stats"
        algo = "smac_deepdb_no_overhead"
        x = [db_algo_names[11],
             db_algo_names[6],
             db_algo_names[5],
             db_algo_names[1]]
        left_values = [11182, 10758, 22035, 29224]
        self.draw_bar_chart(x, left_values, [], [], "{}_{}".format(algo, db),
                            left_y_max=30000, enable_right=False)

    def test_qo_knob_imdb_no_overhead(self):
        db = "imdb"
        algo = "bao_smac_no_overhead"
        x = [db_algo_names[3],
             db_algo_names[4],
             db_algo_names[6],
             db_algo_names[1]]
        left_values = [426, 628, 339, 550]

        self.draw_bar_chart(x, left_values, [], [], "{}_{}".format(algo, db),
                            left_y_max=650, enable_right=False)

    def test_qo_card_imdb_no_overhead(self):
        db = "imdb"
        algo = "bao_deepdb_no_overhead"
        x = [db_algo_names[7],
             db_algo_names[4],
             db_algo_names[5],
             db_algo_names[1]]
        left_values = [4921, 5604, 4854, 5458]
        self.draw_bar_chart(x, left_values, [], [], "{}_{}".format(algo, db),
                            left_y_max=6000, enable_right=False)

    def test_knob_card_imdb_no_overhead(self):
        db = "imdb"
        algo = "smac_deepdb_no_overhead"
        x = [db_algo_names[11],
             db_algo_names[6],
             db_algo_names[5],
             db_algo_names[1]]
        left_values = [2573, 2496, 4854, 5458]
        self.draw_bar_chart(x, left_values, [], [], "{}_{}".format(algo, db),
                            left_y_max=6000, enable_right=False)

    def get_fig_name(self, algo, db):
        return "{}_{}".format(algo, db)

    # read xlsx file by dataframe of pandas
    def read_data(self, algo, db):
        file_path = "Experiment/Data/{}_{}.xlsx".format(algo, db)
        df: DataFrame = pd.read_excel(file_path, header=0)

        # get sum value
        value = df.iloc[0, :]
        return list(df.columns), list(value)

    def draw_bar_chart(self, left_x, left_values: list, right_x, right_values: list, file,
                       bar_width=0.12, left_y_max=None, enable_right=True, enable_left_hatch=False):
        gap = 0.5
        left_y_label = "End To End Time(s)"
        right_y_label = "Overhead Time(s)"
        fig, ax = plt.subplots()
        # fig.figure(figsize=(12, 10))
        cur_font_size = font_size
        # 绘制前四个bar，使用左边的坐标轴
        colors = [name_2_color[name.lower()] for name in left_x]
        colors = [to_rgb_tuple(color) for color in colors]
        x = list(range(0, len(left_x)))
        # 添加pilot 的时间作为堆叠
        # ax.bar(x[0:1], end_to_end_time, color=to_rgb_tuple(name_2_color[pilot_scope_col_name.lower()]))
        hatch = "o" if enable_left_hatch else ""
        ax.bar(x, left_values, color=colors, hatch=hatch)
        # ax.bar([1, 2, 3, 4], data_left_stacked, color='g', bottom=data_left)
        ax.set_ylabel(left_y_label, fontsize=cur_font_size)
        ax.set_ylim(None, left_y_max)

        ax.tick_params(axis='y', labelsize=cur_font_size)
        ax.set_xticks([])

        if enable_right:
            # 创建第二个坐标轴对象
            ax2 = ax.twinx()

            # # 控制最小时间
            max_value = max(right_values)
            right_values = [max_value * self.min_ratio if (v < max_value * self.min_ratio) and v > 0 else v for v in
                            right_values]

            # 绘制后两个bar，使用右边的坐标轴
            colors = [name_2_color[name.lower()] for name in right_x]
            colors = [to_rgb_tuple(color) for color in colors]
            start = len(x)
            x2 = list(range(start, start + len(right_x)))
            x2 = [gap + v for v in x2]
            ax2.bar(x2, right_values, color=colors, hatch="/")
            ax2.set_ylabel(right_y_label, fontsize=cur_font_size)
            ax2.set_xticks([])
            ax.axvline(x=(x[-1] + x2[0]) / 2, color='black', linestyle='--')
            ax2.tick_params(axis='y', labelsize=cur_font_size)

        # plt.ylabel("Total Time(Minutes)", fontsize=cur_font_size)
        # plt.xlabel("# of queries", fontsize=cur_font_size)
        # plt.yticks(size=cur_font_size)
        # plt.xticks(
        #     [i for i in range(len(values)) if i % x_gap == 0],
        #     [i for i in range(len(values)) if i % x_gap == 0],
        #     size=cur_font_size, weight='bold')

        plt.grid(axis='y', linestyle='--')
        plt.tight_layout()
        plt.savefig('../Fig/{}.pdf'.format(file), format='pdf')
        plt.show()

    def colors2legend_bar(self, colors, names, hatches, file_name, handletextpad=1.0, columnspacing=1.0,
                          handlelength=1.0, ncol=None):
        ncol = len(colors) / 2 if ncol is None else ncol
        # 创建一个空白的图形
        fig = plt.figure(figsize=(120, 12))

        # 添加需要的图例
        for i in range(len(colors)):
            hatch = "" if hatches is None else hatches[i]
            plt.bar([0], [0], label=names[i], hatch=hatch, color=to_rgb_tuple(colors[i]))
            # plt.bar([0], [0], label=names[i], color=to_rgb_tuple(colors[i]))

        # ax.legend(loc='upper center', bbox_to_anchor=(0.5, 1.15), ncol=len(colors), facecolor='gray', edgecolor='black')
        legend = plt.legend(loc='upper center', bbox_to_anchor=(0.5, 0.9), ncol=ncol,
                            fontsize=font_size + 30,
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
        # pdf = PdfPages('../Fig/{}.pdf'.format(file_name))
        # pdf.savefig(fig)
        plt.savefig('../Fig/{}.pdf'.format(file_name))
        # pdf.close()
        # plt.show()


if __name__ == '__main__':
    unittest.main()
