#include "component.h"
#include "create.h"
#include <stdio.h>

void btx_push_usr_messages(struct common_data_s *common_data) {
    printf("ENV: %s\n", common_data->usr_params->display );
    btx_push_message_lttng_ust_ze_profiling_event_profiling_results(common_data, 10, 10, 20);
    btx_push_message_lttng_ust_ze_profiling_event_profiling_results(common_data, 11, 10, 30);
    btx_push_message_lttng_ust_ze_profiling_event_profiling_results(common_data, 12, 10, 40);
}
