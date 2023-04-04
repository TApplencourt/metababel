#include <stdio.h>
#include <inttypes.h>
#include "component.h"
#include "upstream.h"
#include "downstream.h"

struct usr_data_s {
    int roger_count;
    int bernard_count;
};

void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
    /* User allocates its own data structure */
    struct usr_data_s *data = (struct usr_data_s *)  malloc(sizeof(struct usr_data_s));
    /* User makes our API usr_data to point to his/her data structure */
    *usr_data = data;
    /* Now user can preserve changes on his/her structure among different callbacks calls */
    data->roger_count = 0;
    data->bernard_count = 0;
    
}
void btx_finalize_usr_data(void *btx_handle, void *usr_data) {
    /* User cast the API usr_data that was already initialized with his/her data */
    struct usr_data_s *data = (struct usr_data_s *) usr_data;
    // Now we can push some messages from the finalize
    for (int l=0; l < 10; l++) {
        btx_push_message_my_WTF(btx_handle, l, (double) l + 0.12);
    }
    /* User do some stuff with the saved data */
    printf("roger %d, bernard %d \n", data->roger_count, data->bernard_count);
    /* Use has to deallocate the memory he/she requested for his/her data structure */
    free(data);
}

void roger(void *btx_handle, void *usr_data, int32_t i, int32_t j, uint32_t k) {
    struct usr_data_s *data = (struct usr_data_s *) usr_data;
    data->roger_count += 1;
    for (int l=0; l < 100; l++) {
        btx_push_message_my_WTF(btx_handle, l, (double) l + 0.12);
    }
}

void bernard(void *btx_handle, void *usr_data, int32_t i, int32_t j, uint32_t k) {
    struct usr_data_s *data = (struct usr_data_s *) usr_data;
    data->bernard_count += 1;
    printf("BERNARD\n");
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_lttng_ust_ze_profiling_event_profiling_results(btx_handle, &roger);
  btx_register_callbacks_lttng_ust_ze_profiling_event_profiling_results(btx_handle, &bernard);
}
