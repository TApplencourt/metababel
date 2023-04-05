#include "component.h"
#include "downstream.h"
#include <stdio.h>

void btx_initialize_usr_data(common_data_t *common_data, void **usr_data) {
}

btx_source_status_t btx_push_usr_messages(struct common_data_s *common_data, void *usr_data) {
    params_t *params = (params_t*) malloc(sizeof(params_t));
    btx_read_params(common_data, params);
    printf("PARAM DISPLAY: %s\n", params->display);
    free(params);
    btx_push_message_lttng_ust_ze_profiling_event_profiling_results(common_data, 10, 10, 20);
    btx_push_message_lttng_ust_ze_profiling_event_profiling_results(common_data, 11, 10, 30);
    btx_push_message_lttng_ust_ze_profiling_event_profiling_results(common_data, 12, 10, 40);
    return BTX_SOURCE_END;
}
