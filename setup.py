from setuptools import setup, find_packages
import os

setup(
    name='dcren',
    version='0.1',
    packages=find_packages(where=os.getcwd())
)