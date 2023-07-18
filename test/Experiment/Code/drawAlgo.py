import unittest
import pandas as pd
from matplotlib import pyplot as plt
from pandas import DataFrame


class MyTestCase(unittest.TestCase):
    def test_something(self):
        self.assertEqual(True, False)  # add assertion here

    def test_draw_bao_stats(self):
        db = "stats"
        algo = "bao"
        self.draw_bao(db, algo)

    def test_draw_bao_imdb(self):
        db = "imdb"
        algo = "bao"
        self.draw_bao(db, algo)

    def test_draw_extend_stats(self):
        db = "stats"
        algo = "extend"
        self.draw_extend(db, algo)

    def test_draw_extend_imdb(self):
        db = "imdb"
        algo = "extend"
        self.draw_extend(db, algo)

    def draw_bao(self, db, algo):
        name, values = self.read_data(algo, db)
        self.draw_bar(name, values, self.get_fig_name(algo, db), "Modules", "Time(s)", True)

    def draw_extend(self, db, algo):
        name, values = self.read_data(algo, db)
        self.draw_bar(name, values, self.get_fig_name(algo, db), "Modules", "Time(s)", True)

    def get_fig_name(self, algo, db):
        return "{}_{}".format(algo, db)

    # read xlsx file by dataframe of pandas
    def read_data(self, algo, db):
        file_path = "Experiment/Data/{}_{}.xlsx".format(algo, db)
        df: DataFrame = pd.read_excel(file_path, header=0)

        # get sum value
        value = df.iloc[0, :]
        return list(df.columns), list(value)

    def draw_bar(self, names, values, file_name, x_title="algos", y_title="Time(s)", is_rotation=False):
        plt.bar(names, values)

        # 设置x轴和y轴标签
        plt.xlabel(x_title)
        plt.ylabel(y_title)
        if is_rotation:
            plt.xticks(rotation=45)
        plt.subplots_adjust(bottom=0.2)
        # 保存图像
        plt.savefig('Experiment/Fig/{}.pdf'.format(file_name), format='pdf')
        plt.show()


if __name__ == '__main__':
    unittest.main()
