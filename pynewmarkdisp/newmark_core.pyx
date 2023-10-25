# cython: language_level=3
# cython: boundscheck=False
# cython: nonecheck=False
# cython: wraparound=False

from cython.parallel import prange
import cython
import numpy as np

from libc.math cimport fabs


cdef inline double ctrapz(double[:] y, double[:] x) nogil:
    """
    Calculate the area under the curve y=f(x) by the trapezoidal rule method.
    """
    return 0.5 * (x[1] - x[0]) * (y[1] + y[0])


@cython.binding(True)
@cython.linetrace(True)
def first_newmark_integration(double[:] time, double[:] accel, double ay):
    cdef:
        int length = time.shape[0]
        double[:] vel = np.zeros(length)
        double[:] adjusted_accel = np.empty_like(accel)
        int i, j
        double v

    for j in range(length):
        adjusted_accel[j] = accel[j] - ay

    for i in prange(1, length, nogil=True, schedule='guided'):
        v = 0.0
        if accel[i] > ay:
            v = vel[i-1] + ctrapz(y=adjusted_accel[i-1:i+1], x=time[i-1:i+1])
        elif accel[i] < ay and vel[i-1] > 0:
            v = vel[i-1] - fabs(ctrapz(y=accel[i-1:i+1], x=time[i-1:i+1]))
        vel[i] = max(v, 0)

    return np.array(vel)
