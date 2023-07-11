import matplotlib.pyplot as plt

from common.Util import sum_list


class Drawer:

    @classmethod
    def draw_bar(cls, name_2_values: dict, file_name, x_title="algos", y_title="Time(s)",is_rotation=False):
        names = list(name_2_values.keys())

        values=[]
        for vs in name_2_values.values():
            values.append(sum_list(vs) / len(vs) if hasattr(vs, '__iter__') else vs)

        plt.bar(names, values)

        # 设置x轴和y轴标签
        plt.xlabel(x_title)
        plt.ylabel(y_title)
        if is_rotation:
            plt.xticks(rotation=45)
        plt.subplots_adjust(bottom=0.2)
        # 保存图像
        plt.savefig('./Results/{}.png'.format(file_name))
        plt.show()

    @classmethod
    def draw_line(cls, name_2_values: dict):
        pass
