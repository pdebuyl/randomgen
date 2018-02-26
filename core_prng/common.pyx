import numpy as np
cimport numpy as np
from common cimport *

np.import_array()

cdef check_output(object out, object dtype, object size):
    if out is None:
        return
    cdef np.ndarray out_array = <np.ndarray>out
    if not (np.PyArray_CHKFLAGS(out_array, np.NPY_CARRAY) or
            np.PyArray_CHKFLAGS(out_array, np.NPY_FARRAY)):
        raise ValueError('Supplied output array is not contiguous, writable or aligned.')
    if out_array.dtype != dtype:
        raise TypeError('Supplied output array has the wrong type. '
                        'Expected {0}, got {0}'.format(dtype, out_array.dtype))
    if size is not None:
        # TODO: enable this !!! if tuple(size) != out_array.shape:
        raise ValueError('size and out cannot be simultaneously used')


cdef object double_fill(random_double_anon *random_double, void *state, object size, object lock, object out):
    cdef double *out_array_data
    cdef np.ndarray out_array
    cdef np.npy_intp i, n

    if size is None and out is None:
        with lock:
            return random_double[0](state)

    if out is not None:
        check_output(out, np.double, size)
        out_array = <np.ndarray>out
    else:
        out_array = <np.ndarray>np.empty(size, np.double)

    n = np.PyArray_SIZE(out_array)
    out_array_data = <double *>np.PyArray_DATA(out_array)
    with lock, nogil:
        for i in range(n):
            out_array_data[i] = random_double[0](state)
    return out_array