from distutils.core import setup
from setuptools.extension import Extension
from Cython.Build import cythonize
import numpy as np


with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()


extensions = [
    Extension(
        name="pynewmarkdisp.newmark_core",
        sources=["pynewmarkdisp/newmark_core.pyx"],
        define_macros=[('CYTHON_TRACE', '1')],
        extra_compile_args=['-fopenmp'],
        extra_link_args=['-fopenmp'],
    ),
]


setup(
    name="pynewmarkdisp",
    version="0.1.0",
    description="My library's short description.",
    long_description=long_description,
    long_description_content_type="text/markdown",
    ext_modules = cythonize(extensions, compiler_directives={'language_level': 3, 'linetrace': True, "binding": True}),
    include_dirs=[np.get_include()]
)
