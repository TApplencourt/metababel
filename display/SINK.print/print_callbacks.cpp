#include "print_callbacks.hpp"


void btx_initialize_usr_data(common_data_t *common_data, void **usr_data) {
    /* User allocates its own data structure */
    struct tally_dispatch *data = new struct tally_dispatch;
    /* User makes our API usr_data to point to his/her data structure */
    *usr_data = data;

    params_t *params = (params_t*) malloc(sizeof(params_t));
    btx_read_params(common_data, params);

    data->display_compact = params->display_compact;
    data->display_human = params->display_human;
    data->display_metadata = params->display_metadata;
    data->display_name_max_size = params->display_name_max_size;

    free(params);
}

void btx_finalize_usr_data(common_data_t *common_data, void *usr_data) {
    /* User cast the API usr_data that was already initialized with his/her data */
    struct tally_dispatch *data = new struct tally_dispatch;

    free(data);
}

void tally_host_usr_callbacks(
    common_data_t *common_data, void *usr_data, const char* hostname, int64_t vpid, 
    uint64_t vtid, int64_t backend, const char* name, uint64_t dur, uint64_t min, 
    uint64_t max, uint64_t count, uint64_t error
)
{
    std::cout << "tally_host_usr_callbacks" << std::endl;
}

void tally_device_usr_callbacks(
    common_data_t *common_data, void *usr_data, const char* hostname, int64_t vpid,
    uint64_t vtid, int64_t backend, const char* name, uint64_t did, uint64_t sdid,
    uint64_t dur, uint64_t min, uint64_t max, uint64_t count, uint64_t error
)
{
    std::cout << "tally_device_usr_callbacks" << std::endl;
}

void tally_traffic_usr_callbacks(
    common_data_t *common_data, void *usr_data, const char* hostname, int64_t vpid,
    uint64_t vtid, int64_t backend, const char* name, uint64_t dur, uint64_t min,
    uint64_t max, uint64_t count, uint64_t error
)
{
    std::cout << "tally_traffic_usr_callbacks"  << std::endl;
}

void lttng_device_name_usr_callbacks(
    common_data_t *common_data, void *usr_data, const char* hostname, int64_t vpid,
    uint64_t vtid, int64_t backend, const char* name, uint64_t did
)
{
    std::cout << "lttng_device_name_usr_callbacks" << std::endl;
}

void lttng_ust_thapi_metadata_usr_callbacks(
    common_data_t *common_data, void *usr_data, const char* hostname, int64_t vpid,
    uint64_t vtid, int64_t backend, const char* metadata
)
{
    std::cout << "lttng_ust_thapi_metadata_usr_callbacks" << std::endl;
} 

void btx_register_usr_callbacks(name_to_dispatcher_t** name_to_dispatcher) {
    btx_register_callbacks_tally_host(name_to_dispatcher,&tally_host_usr_callbacks);
    btx_register_callbacks_tally_device(name_to_dispatcher,&tally_device_usr_callbacks);
    btx_register_callbacks_tally_traffic(name_to_dispatcher,&tally_traffic_usr_callbacks);
    btx_register_callbacks_lttng_device_name(name_to_dispatcher,&lttng_device_name_usr_callbacks);
    btx_register_callbacks_lttng_ust_thapi_metadata(name_to_dispatcher,&lttng_ust_thapi_metadata_usr_callbacks);
}
