import time

from matplotlib import pyplot as plt, font_manager

from matplotlib.backends.backend_pdf import PdfPages

font_size = 20

framework_name = "PilotScope"
query_time_name = "Query Time (ML) "
pilot_scope_col_name = "Overhead"
right_bar_names = ["Pull Operator Time", "Push Operator Time", "Communication Time", "I/O Time"]
db_algo_names = [
    "PostgreSQL + Installing PilotScope + Apply AI4DB Algorithm",
    "PostgreSQL + Installing PilotScope + Not Apply AI4DB Algorithm",
    "PostgreSQL Without Installing PilotScope",
    
    "PostgreSQL + Installing PilotScope + Apply Bao and SMAC",
    "PostgreSQL + Installing PilotScope + Apply Bao",
    "PostgreSQL + Installing PilotScope + Apply DeepDB",
    "PostgreSQL + Installing PilotScope + Apply SMAC",
    "PostgreSQL + Installing PilotScope + Apply Bao and DeepDB",

    "Spark + Installing PilotScope + Apply AI4DB Algorithm",
    "Spark + Installing PilotScope + Not Apply AI4DB Algorithm",
    "Spark Without Installing PilotScope",
]

name_2_color = {
    query_time_name.lower(): "rgb(216,56,58)",
    db_algo_names[0].lower(): "rgb(216,56,58)",
    db_algo_names[8].lower(): "rgb(244,177,131)",
    "pilotscope+postgresql": "rgb(47,127,193)",
    db_algo_names[1].lower(): "rgb(47,127,193)",
    db_algo_names[9].lower(): "rgb(47,127,193)",
    "postgresql": "rgb(20,81,124)",
    db_algo_names[2].lower(): "rgb(20,81,124)",
    db_algo_names[10].lower(): "rgb(20,81,124)",

    db_algo_names[3].lower(): "rgb(216,56,58)",
    db_algo_names[4].lower(): "rgb(147,148,231)",
    db_algo_names[5].lower(): "rgb(40,71,92)",
    db_algo_names[6].lower(): "rgb(243,210,102)",
    db_algo_names[7].lower(): "rgb(217,194,173)",

    right_bar_names[0].lower(): "rgb(147,148,231)",
    right_bar_names[1].lower(): "rgb(243,210,102)",
    right_bar_names[2].lower(): "rgb(150,195,125)",
    right_bar_names[3].lower(): "rgb(224,210,163)",

    " ":"rgb(255,255,255)",
    "push hint": "rgb(147,148,231)",
    "pull plan": "rgb(243,210,102)",
    "http": "rgb(216,56,58)",
    "storage": "rgb(224,210,163)",
    "ml_method": "rgb(92,147,148)",
    pilot_scope_col_name.lower(): "rgb(89,46,30)",
    "push index": "rgb(224,210,163)",
    "push knob": "rgb(40,71,92)",
    "push subquery": "rgb(242,202,167)",
    "pull subquery": "rgb(217,194,173)",
}


def connect_framework_algo(algo):
    return "{}+{}".format(framework_name, algo)


def get_plt():
    path = 'Experiment/Linux-Libertine.ttf'
    font_manager.fontManager.addfont(path)
    prop = font_manager.FontProperties(fname=path)
    plt.rcParams['font.family'] = prop.get_name()
    plt.rcParams['font.weight'] = 'bold'
    plt.rcParams['mathtext.default'] = 'regular'
    return plt


def to_rgb_tuple(color: str):
    return tuple([int(c) / 255 for c in color[4:-1].split(",")])


def _unify_layout(fig):
    fig.update_xaxes(showline=True, linewidth=1, linecolor='black', mirror=True)
    fig.update_yaxes(showline=True, linewidth=1, linecolor='black', mirror=True, gridcolor='lightgrey')
    fig['layout'].update(margin=dict(l=0, r=0, b=0, t=0))
    fig.update_layout(
        font=dict(
            # family="Arial Bold",
            family="Times New Roman",
            # family=font_path,
        )
    )


def capitalize(s: str):
    return s[0].upper() + s[1:]


def to_bold(values):
    return ["<b>{}</b>".format(x) for x in values]


def colors2legend(colors, names, lines, markers, file_name):
    # 创建一个空白的图形
    fig, ax = plt.subplots(figsize=(33, 5))

    # 添加需要的图例
    for i in range(len(colors)):
        ax.plot([], [], label=names[i], color=to_rgb_tuple(colors[i]), marker=markers[i])

    # ax.legend(loc='upper center', bbox_to_anchor=(0.5, 1.15), ncol=len(colors), facecolor='gray', edgecolor='black')
    legend = ax.legend(loc='upper center', bbox_to_anchor=(0.5, 0.9), ncol=len(colors), fontsize=font_size)
    ax.axis('off')
    legend_margin_width = 10
    legend.get_frame().set_linewidth(legend_margin_width)
    # 调节线的粗细和形状

    width = 15
    for i in range(len(colors)):
        legend.get_lines()[i].set_linewidth(width)
        legend.legendHandles[i].set_linestyle(lines[i])
    plt.show()
    pdf = PdfPages('draw_fig/{}.pdf'.format(file_name))
    # plt.savefig('draw_fig/{}.pdf'.format(file_name))
    pdf.savefig(fig)
    pdf.close()


def colors2legend_bar(colors, names, hatches, file_name, handletextpad=1.0, columnspacing=1.0, handlelength=1.0):
    # 创建一个空白的图形
    fig = plt.figure(figsize=(58, 5))

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
    pdf = PdfPages('draw_fig/{}.pdf'.format(file_name))
    # plt.savefig('draw_fig/{}.pdf'.format(file_name))
    pdf.savefig(fig)
    pdf.close()
