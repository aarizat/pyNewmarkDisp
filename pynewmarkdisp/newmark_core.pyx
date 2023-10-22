# cython: language_level=3
# cython: boundscheck=False
# cython: nonecheck=False
# cython: wraparound=False

import numpy as np


cdef double ctrapz(double[:] y, double[:] x):
    """
    Calculate the area under the curve y=f(x) by the trapezoidal rule method.

    This function is optimized for speed using Cython.

    Parameters
    ----------
    y : (n, ) ndarray
        1D array with the values of the function y=f(x).
    x : (n, ) ndarray
        1D array with the values of the independent variable x.

    Returns
    -------
    area : float
        Area under the curve y=f(x) calculated by the trapezoidal rule method.
    """
    cdef:
        int n = x.shape[0]
        int i
        double area = 0.0

    for i in range(n-1):
        area += 0.5 * (x[i+1] - x[i]) * (y[i+1] + y[i])
    return area


def first_newmark_integration(double[:] time, double[:] accel, double ay):
    cdef:
        int length = time.shape[0]
        double[:] vel = np.zeros(length)
        double[:] adjusted_accel
        int i, j
        double v

    for i in range(1, length):

        adjusted_accel = accel[i-1:i+1].copy()
        for j in range(2):
            adjusted_accel[j] -= ay

        if accel[i] > ay:
            v = vel[i-1] + ctrapz(y=adjusted_accel, x=time[i-1:i+1])
        elif accel[i] < ay and vel[i-1] > 0:
            v = vel[i-1] - abs(ctrapz(y=accel[i-1:i+1], x=time[i-1:i+1]))
        else:
            v = 0
        vel[i] = max(v, 0)

    return np.array(vel)
