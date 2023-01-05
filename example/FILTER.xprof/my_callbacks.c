#include <stdio.h>
#include <inttypes.h>
#include "component.h"
#include "dispatch.h"
#include "create.h"

void btx_initialize_usr_data(common_data_t *common_data) {}
void btx_finalize_usr_data(common_data_t *common_data) {}

void roger(struct common_data_s *common_data, int32_t i, int32_t j, uint32_t k) {
    for (int l=0; l < 5; l++) {
        btx_push_message_my_WTF(common_data, i, (double) l + 0.12);
    }
}

void bernard(struct common_data_s *common_data, int32_t i, int32_t j, uint32_t k) {
    printf("BERNARD\n");
}

void btx_register_usr_callbacks(name_to_dispatcher_t** name_to_dispatcher) {
  btx_register_callbacks_lttng_ust_ze_profiling_event_profiling_results(name_to_dispatcher, &roger);
  btx_register_callbacks_lttng_ust_ze_profiling_event_profiling_results(name_to_dispatcher, &bernard);
}
