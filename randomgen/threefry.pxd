from libc.stdlib cimport malloc, free
from cpython.pycapsule cimport PyCapsule_New

from randomgen.common cimport *
from randomgen.distributions cimport brng_t

DEF THREEFRY_BUFFER_SIZE=4

cdef extern from 'src/threefry/threefry.h':
    struct s_r123array4x64:
        uint64_t v[4]

    ctypedef s_r123array4x64 r123array4x64

    ctypedef r123array4x64 threefry4x64_key_t
    ctypedef r123array4x64 threefry4x64_ctr_t

    struct s_threefry_state:
        threefry4x64_ctr_t *ctr;
        threefry4x64_key_t *key;
        int buffer_pos;
        uint64_t buffer[THREEFRY_BUFFER_SIZE];
        int has_uint32
        uint32_t uinteger

    ctypedef s_threefry_state threefry_state

    uint64_t threefry_next64(threefry_state *state)  nogil
    uint32_t threefry_next32(threefry_state *state)  nogil
    void threefry_jump(threefry_state *state)
    void threefry_advance(uint64_t *step, threefry_state *state)

cdef inline uint64_t threefry_uint64(void* st) nogil:
    return threefry_next64(<threefry_state *>st)

cdef inline uint32_t threefry_uint32(void *st) nogil:
    return threefry_next32(<threefry_state *> st)

cdef inline double threefry_double(void* st) nogil:
    return uint64_to_double(threefry_next64(<threefry_state *>st))

cdef class ThreeFry:
    cdef threefry_state  *rng_state
    cdef brng_t *_brng
    cdef public object capsule
    cdef object _ctypes
    cdef object _cffi
    cdef object _generator

    cdef inline _reset_state_variables(self):
        self.rng_state.has_uint32 = 0
        self.rng_state.uinteger = 0
        self.rng_state.buffer_pos = THREEFRY_BUFFER_SIZE
        for i in range(THREEFRY_BUFFER_SIZE):
            self.rng_state.buffer[i] = 0
