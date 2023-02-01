#include <stdio.h>
#include <inttypes.h>
#include "component.h"
#include "dispatch.h"
#include "create.h"
#include <map>

struct usr_data_s {
    int roger_count;
    int bernard_count;
};

void btx_initialize_usr_data(common_data_t *common_data, void **usr_data) {
    struct usr_data_s *data = (struct usr_data_s*) malloc(sizeof(struct usr_data_s));
    *usr_data = data;
    data->roger_count = 0;
    data->bernard_count = 0;
    
}
void btx_finalize_usr_data(common_data_t *common_data, void *usr_data) {
    struct usr_data_s *data = (struct usr_data_s *) usr_data;
    printf("roger %d, bernard %d \n", data->roger_count, data->bernard_count);
}

void roger(struct common_data_s *common_data, void *usr_data, int32_t i, int32_t j, uint32_t k) {
    struct usr_data_s *data = (struct usr_data_s *) usr_data;
    data->roger_count += 1;
    for (int l=0; l < 5; l++) {
        btx_push_message_my_WTF(common_data, i, (double) l + 0.12);
    }
}

void bernard(struct common_data_s *common_data, void *usr_data, int32_t i, int32_t j, uint32_t k) {
    struct usr_data_s *data = (struct usr_data_s *) usr_data;
    data->bernard_count += 1;
    printf("BERNARD\n");
}

void btx_register_usr_callbacks(name_to_dispatcher_t** name_to_dispatcher) {
  btx_register_callbacks_lttng_ust_ze_profiling_event_profiling_results(name_to_dispatcher, &roger);
  btx_register_callbacks_lttng_ust_ze_profiling_event_profiling_results(name_to_dispatcher, &bernard);
}
