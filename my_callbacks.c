#include "dispacher_t.h"
#include "xprof_dispatch.h"

void usr_register_callbacks(name_to_dispatcher_t** name_to_dispatcher) {
  btx_register_callbacks_lttng_ust_ze_profiling_event_profiling_results(name_to_dispatcher, 10);
  btx_register_callbacks_lttng_ust_ze_profiling_event_profiling_results(name_to_dispatcher, 20);
}
