#include "component.h"
#include "upstream.h"
#include "downstream.h"
#include "babeltrace2/babeltrace.h"

#include "tally.hpp"


void btx_initialize_usr_data(common_data_t *common_data, void **usr_data) {
    /* User allocates its own data structure */
    aggreg_data_t *data = new aggreg_data_t;
    /* User makes our API usr_data to point to his/her data structure */
    *usr_data = data;
}

void btx_finalize_usr_data(common_data_t *common_data, void *usr_data) {
    /* TODO: User need to cast the usr_data, we can avoid casting by wrapping this function
       and make the wrapper to do the casting for us.
    */
    aggreg_data_t *data = (aggreg_data_t *) usr_data;
    
    for (const auto &[key,tally] : data->host){
        btx_push_message_aggreg_host(
            common_data,
            std::get<0>(key).c_str(),
            std::get<1>(key),
            std::get<2>(key),
            std::get<3>(key),
            std::get<4>(key).c_str(),
            tally.duration,
            tally.min,
            tally.max,
            tally.count,
            tally.error
        );
    }

    for (const auto &[key,tally] : data->device){
        btx_push_message_aggreg_kernel(
            common_data,
            std::get<0>(key).c_str(),
            std::get<1>(key),
            std::get<2>(key),
            std::get<3>(key),
            std::get<4>(key).c_str(),
            std::get<5>(key).c_str(),
            std::get<6>(key),
            std::get<7>(key),
            tally.duration,
            tally.min,
            tally.max,
            tally.count,
            tally.error
        );
    }

    for (const auto &[key,tally] : data->traffic){
        btx_push_message_aggreg_traffic(
            common_data,
            std::get<0>(key).c_str(),
            std::get<1>(key),
            std::get<2>(key),
            std::get<3>(key),
            std::get<4>(key).c_str(),
            tally.duration,
            tally.min,
            tally.max,
            tally.count,
            tally.error
        );
    }

    /* De-allocate user data */
    delete data;
}

void lttng_host_usr_callback(
    struct common_data_s *common_data, void *usr_data,   const char* hostname,
    int64_t vpid, uint64_t vtid, int64_t ts, int64_t backend_id, const char* name,
    uint64_t dur, bt_bool err
) 
{
    aggreg_data_t *data = (aggreg_data_t *) usr_data;

    TallyCoreTime a{dur, err};
    data->host[hpt_backend_function_name_t(hostname, vpid, vtid, backend_id, name)] += a;
}

void lttng_device_usr_callback(
    struct common_data_s *common_data, void* usr_data, 
    const char* hostname, int64_t vpid, uint64_t vtid, int64_t ts,
    int64_t backend, const char* name, uint64_t dur, uint64_t did,
    uint64_t sdid, bt_bool err, const char* metadata
)
{
    aggreg_data_t *data = (aggreg_data_t *) usr_data;

    TallyCoreTime a{dur, err};
    data->device[hpt_backend_function_name_meta_dsd_t(hostname, vpid, vtid, backend, name, metadata, did, sdid)] += a;
}

void lttng_traffic_usr_callback(
    struct common_data_s *common_data, void* usr_data, 
    const char* hostname, int64_t vpid, uint64_t vtid, int64_t ts,
    int64_t backend, const char* name, uint64_t size
)
{
    aggreg_data_t *data = (aggreg_data_t *) usr_data;

    TallyCoreByte a{size, false};
    data->traffic[hpt_backend_function_name_t(hostname, vpid, vtid, backend, name)] += a;
}

void btx_register_usr_callbacks(name_to_dispatcher_t** name_to_dispatcher) {
    btx_register_callbacks_lttng_host(name_to_dispatcher, &lttng_host_usr_callback);
    btx_register_callbacks_lttng_device(name_to_dispatcher, &lttng_device_usr_callback);
    btx_register_callbacks_lttng_traffic(name_to_dispatcher, &lttng_traffic_usr_callback);
}
