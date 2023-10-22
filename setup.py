from distutils.core import setup
from setuptools.extension import Extension
from Cython.Build import cythonize
import numpy as np


with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

extensions = [
    Extension("pynewmarkdisp.newmark_core", ["pynewmarkdisp/newmark_core.pyx"]),
]

setup(
    name="pynewmarkdisp",
    version="0.1.0",
    description="My library's short description.",
    long_description=long_description,
    long_description_content_type="text/markdown",
    ext_modules = cythonize(extensions),
    include_dirs=[np.get_include()]
)
