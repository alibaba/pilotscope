import matplotlib.pyplot as plt
import numpy as np

# 生成示例数据
N = 4
ind = np.arange(N)
width = 0.35
men_means = [20, 35, 30, 35]
women_means = [25, 32, 34, 20]

# 创建图形和坐标轴对象
fig, ax = plt.subplots()

# 绘制柱状图
rects1 = ax.bar(ind, men_means, width, color='r')
rects2 = ax.bar(ind + width, women_means, width, color='b')

# 添加标题和标签
ax.set_ylabel('Scores')
ax.set_title('Scores by group and gender')

# 添加x轴刻度标签
ax.set_xticks(ind + width / 2)
ax.set_xticklabels(('G1', 'G2', 'G3', 'G4'))

# 添加图例
# ax.legend((rects1[0], rects2[0]), ('Men', 'Women'), loc='upper center', bbox_to_anchor=(0.5, -0.15), ncol=2)
ax.legend((rects1[0], rects2[0]), ('Men', 'Women'), loc='upper center', bbox_to_anchor=(0.5, -0.15), ncol=2)

plt.show()