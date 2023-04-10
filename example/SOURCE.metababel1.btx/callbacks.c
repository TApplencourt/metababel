#include <metababel/metababel.h>
#include <stdio.h>

void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
}

btx_source_status_t btx_push_usr_messages(void *btx_handle, void *usr_data) {
    params_t *params = (params_t*) malloc(sizeof(params_t));
    btx_read_params(btx_handle, params);
    printf("PARAM DISPLAY: %s\n", params->display);
    free(params);
    btx_push_message_lttng_ust_ze_profiling_event_profiling_results(btx_handle, 10, 10, 20);
    btx_push_message_lttng_ust_ze_profiling_event_profiling_results(btx_handle, 11, 10, 30);
    btx_push_message_lttng_ust_ze_profiling_event_profiling_results(btx_handle, 12, 10, 40);
    return BTX_SOURCE_END;
}
