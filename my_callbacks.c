#include <stdio.h>
#include "dispacher_t.h"
#include "xprof_dispatch.h"
#include <inttypes.h>

void roger(int32_t i, int32_t j, uint32_t k) {
    printf("ROGER %" PRId32 "\n", i);
}

void bernard(int32_t i, int32_t j, uint32_t k) {
    printf("BERNARD\n");
}

void usr_register_callbacks(name_to_dispatcher_t** name_to_dispatcher) {
  btx_register_callbacks_lttng_ust_ze_profiling_event_profiling_results(name_to_dispatcher, &roger);
  btx_register_callbacks_lttng_ust_ze_profiling_event_profiling_results(name_to_dispatcher, &bernard);
}
