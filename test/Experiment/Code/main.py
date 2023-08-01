import matplotlib.pyplot as plt

# 数据
data_left = [10, 20, 30, 40]
data_right = [50, 60]
data_left_stacked = [5, 15, 25, 35]

# 创建figure对象
fig, ax = plt.subplots()

# 绘制前四个bar，使用左边的坐标轴
ax.bar([1, 2, 3, 4], data_left, color='b')
ax.bar([1], data_left_stacked[0], color='g')
ax.set_xlabel('左边的x轴')
ax.set_ylabel('左边的y轴', color='b')
ax.tick_params(axis='y', labelcolor='b')

# 创建第二个坐标轴对象
ax2 = ax.twinx()

# 绘制后两个bar，使用右边的坐标轴
ax2.bar([5, 6], data_right, color='r')
ax2.set_ylabel('右边的y轴', color='r')
ax2.tick_params(axis='y', labelcolor='r')

# 显示图形
plt.show()
