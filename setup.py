"""Setup for installation of Autometa."""


import os

from setuptools import setup
from setuptools import find_packages


def read(fname):
    """Read a file from the current directory."""
    return open(os.path.join(os.path.dirname(__file__), fname)).read()


long_description = read("README.md")
version = read("VERSION").strip()

setup(
    name="Automappa",
    python_requires=">=3.7",
    version=version,
    packages=find_packages(exclude=["tests"]),
    package_data={"": ["app/assets/*"]},
    entry_points={
        "console_scripts": [
            "automappa = automappa.__main__:main",
        ]
    },
    author="Evan R. Rees",
    author_email="erees@wisc.edu",
    description="Automappa: An interactive interface for exploration of metagenomes",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/WiscEvan/Automappa",
    license="GNU Affero General Public License v3 or later (AGPLv3+)",
    classifiers=[
        "Programming Language :: Python",
        "Programming Language :: Python :: 3.7",
        "Intended Audience :: Science/Research",
        "Topic :: Scientific/Engineering :: Bio-Informatics",
        "License :: OSI Approved :: GNU Affero General Public License v3 or later (AGPLv3+)",
        "Operating System :: OS Independent",
    ],
)
