#include <stdio.h>
#include <inttypes.h>
#include "component.h"
#include "dispatch.h"
#include <iostream>
#include <tuple>

struct usr_data_s {
    int count;
    std::tuple<int,int> a;
};

void btx_initialize_usr_data(common_data_t *common_data, void **usr_data) {
    struct usr_data_s *data = (struct usr_data_s *)  malloc(sizeof(struct usr_data_s));
    *usr_data = data;
    data->count = 0;
}

void btx_finalize_usr_data(common_data_t *common_data, void *usr_data) {
    struct usr_data_s * toto = (struct usr_data_s *) usr_data;    
    std::cout << "COUNTER "<< toto->count << std::endl;
}

static void roger(struct common_data_s *common_data, void *usr_data, int32_t i, int32_t j, uint32_t k) {
    printf("ROGER %" PRId32 "\n", i);
}

static void bernard(struct common_data_s *common_data, void *usr_data, int32_t i, int32_t j, uint32_t k) {
    struct usr_data_s * toto = (struct usr_data_s *) common_data->usr_data;
    toto->count += 1;
}

void btx_register_usr_callbacks(name_to_dispatcher_t** name_to_dispatcher) {
  btx_register_callbacks_lttng_ust_ze_profiling_event_profiling_results(name_to_dispatcher, &roger);
  btx_register_callbacks_lttng_ust_ze_profiling_event_profiling_results(name_to_dispatcher, &bernard);
}
