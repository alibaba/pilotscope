from __future__ import absolute_import, division, print_function

import setuptools

__name__ = 'pilotscope'
__version__ = '0.1.0'
URL = 'https://github.com/xxxxxxx'

minimal_requires = [
    
]

# test_requires = ['pytest', 'pytest-cov']

setuptools.setup(
    name=__name__,
    version=__version__,
    author="Alibaba Damo Academy",
    author_email="jones.wz@alibaba-inc.com",
    description="Federated learning package",
    # long_description=long_description,
    # long_description_content_type="text/markdown",
    url=URL,
    # download_url=f'{URL}/archive/{__version__}.tar.gz',
    keywords=['deep-learning', 'database'],
    packages=[
        package for package in setuptools.find_packages()
        if package.startswith(__name__)
    ],
    install_requires=minimal_requires,
    python_requires='>=3.8',
)