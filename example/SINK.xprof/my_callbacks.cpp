#include <stdio.h>
#include <inttypes.h>
#include "component.h"
#include "dispatch.h"
#include <iostream>
#include <tuple>

struct usr_data_s {
    int count;
    params_t *params;
    std::tuple<int,int> a;
};

void btx_initialize_usr_data(common_data_t *common_data, void **usr_data) {
    /* User allocates its own data structure */
    struct usr_data_s *data = (struct usr_data_s *)  malloc(sizeof(struct usr_data_s));
    /* User makes our API usr_data to point to his/her data structure */
    *usr_data = data;
    /* Now user can preserve changes on his/her structure among different callbacks calls */
    data->count = 0;
}

void btx_finalize_usr_data(common_data_t *common_data, void *usr_data) {
    /* User cast the API usr_data that was already initialized with his/her data */
    struct usr_data_s *data = (struct usr_data_s *) usr_data;
    /* User do some stuff with the saved data */
    std::cout << "COUNTER "<< data->count << std::endl;
    /* Use has to deallocate the memory he/she requested for his/her data structure */
    free(data);
}

static void roger(struct common_data_s *common_data, void *usr_data, int32_t i, int32_t j, uint32_t k) {
    printf("ROGER %" PRId32 "\n", i);
}

static void bernard(struct common_data_s *common_data, void *usr_data, int32_t i, int32_t j, uint32_t k) {
    /* In callbacks, the user just  need to cast our API usr_data to his/her data structure */
    struct usr_data_s * data = (struct usr_data_s *) usr_data;
    data->count += 1;
}

void btx_register_usr_callbacks(btx_handle_t** btx_handle) {
  btx_register_callbacks_lttng_ust_ze_profiling_event_profiling_results(btx_handle, &roger);
  btx_register_callbacks_lttng_ust_ze_profiling_event_profiling_results(btx_handle, &bernard);
}
