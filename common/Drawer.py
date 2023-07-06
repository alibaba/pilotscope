import matplotlib.pyplot as plt

from common.Util import sum_list


class Drawer:

    @classmethod
    def draw_bar(cls, name_2_values: dict, file_name, x_title="algos", y_title="Time(s)"):
        names = list(name_2_values.keys())
        values = [sum_list(vs) / len(vs) for vs in name_2_values.values()]

        plt.bar(names, values)

        # 设置x轴和y轴标签
        plt.xlabel(x_title)
        plt.ylabel(y_title)

        plt.show()
        # 保存图像
        plt.savefig('./Results/{}.png'.format(file_name))

    @classmethod
    def draw_line(cls, name_2_values: dict):
        pass
