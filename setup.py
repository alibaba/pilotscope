from __future__ import absolute_import, division, print_function

import setuptools

__name__ = 'pilotscope'
__version__ = '0.1.0'
URL = 'https://github.com/duoyw/PilotScope'

minimal_requires = [
    "APScheduler>=3.10.1","pandas>=2.0.1","psycopg2>=2.9.6","numpy>=1.24.3","SQLAlchemy>=2.0.2","SQLAlchemy-Utils>=0.41.1","joblib>=1.2.0","openpyxl>=3.1.2"
]

requires = minimal_requires + ["torch==2.0.1","scikit-learn==1.2.2","matplotlib==3.7.2","ConfigSpace==0.4.20","smac==1.1.0","prettytable==3.6.0","sqlglot==12.4.0"]
with open("README.md", "r", encoding='UTF-8') as f:
    long_description = f.read()

setuptools.setup(
    name=__name__,
    version=__version__,
    author="Alibaba Damo Academy",
    author_email="red.zr@alibaba-inc.com,lianggui.wlg@alibaba-inc.com,weiwenqing.wwq@alibaba-inc.com,woodybryant.wd@alibaba-inc.com,pengjiazhen.pjz@alibaba-inc.com,xuanyin.wyf@alibaba-inc.com,bolin.ding@alibaba-inc.com,liandefu@ustc.edu.cn,bolongzheng@hust.edu.cn,jingren.zhou@alibaba-inc.com ",
    description="An AI4DB deployment tool. The source code of \"PilotScope: Steering Databases with Machine Learning Drivers\".",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url=URL,
    # download_url=f'{URL}/archive/{__version__}.tar.gz',
    keywords=['database',"artificial intelligence","machine learning"],
    packages=[
        package for package in setuptools.find_packages()
        if package.startswith(__name__)
    ],
    extras_require={
        'dev': requires,
    },
    install_requires=minimal_requires,
    python_requires='>=3.8',
)