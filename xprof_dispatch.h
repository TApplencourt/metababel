#pragma once
#include "dispacher_t.h"
typedef void lttng_ust_ze_profiling_event_profiling_results_callback_f(int64_t,int64_t,uint64_t );

void
btx_register_callbacks_lttng_ust_ze_profiling_event_profiling_results(name_to_dispatcher_t **name_to_dispatcher, void *callback)
;
typedef void lttng_ust_interval_inHost_callback_f(const char*,int64_t,uint64_t,const char*,int64_t,const char*,uint64_t,bt_bool );

void
btx_register_callbacks_lttng_ust_interval_inHost(name_to_dispatcher_t **name_to_dispatcher, void *callback)
;
