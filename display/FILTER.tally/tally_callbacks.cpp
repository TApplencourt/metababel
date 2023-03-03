#include <stdio.h>
#include <inttypes.h>
#include "component.h"
#include "dispatch.h"
#include "create.h"
#include <iostream>

#include "tally_callbacks.hpp"


void btx_initialize_usr_data(common_data_t *common_data, void **usr_data) {
    /* User allocates its own data structure */
    struct tally_dispatch *data = new struct tally_dispatch;
    /* User makes our API usr_data to point to his/her data structure */
    *usr_data = data;
    // Do some initialization...
    params_t *params = (params_t*) malloc(sizeof(params_t));
    btx_read_params(common_data, params);

    data->demangle_name = params->demangle_name;
    data->display_kernel_verbose = params->display_kernel_verbose;
    
    free(params);
}

void btx_finalize_usr_data(common_data_t *common_data, void *usr_data) {
    /* User cast the API usr_data that was already initialized with his/her data */
    struct tally_dispatch *data = (struct tally_dispatch *) usr_data;
    
    // User do some stuff with the saved data...
    for (auto &[key,tally] : data->host){
        btx_push_message_tally_host(
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

    for (auto &[key,tally] : data->device){
        btx_push_message_tally_device(
            common_data,
            std::get<0>(key).c_str(),
            std::get<1>(key),
            std::get<2>(key),
            std::get<3>(key),
            std::get<4>(key).c_str(),
            std::get<5>(key),
            std::get<6>(key),
            tally.duration,
            tally.min,
            tally.max,
            tally.count,
            tally.error
        );
    }

    for (auto &[key,tally] : data->traffic){
        btx_push_message_tally_traffic(
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

    /* Desolate user data */
    delete data;
}

void tally_host_usr_callback(
    struct common_data_s *common_data, void *usr_data,   const char* hostname,
    int64_t vpid, uint64_t vtid, int64_t ts, int64_t backend_id, const char* name,
    uint64_t dur, bt_bool err
) 
{
    struct tally_dispatch *data = (struct tally_dispatch *) usr_data;

    TallyCoreTime a{dur, err};
    data->host[hpt_backend_function_name_t(hostname, vpid, vtid, backend_id, name)] += a;
}

void tally_device_usr_callback(
    struct common_data_s *common_data, void* usr_data, 
    const char* hostname, int64_t vpid, uint64_t vtid, int64_t ts,
    int64_t backend, const char* name, uint64_t dur, uint64_t did,
    uint64_t sdid, bt_bool err, const char* metadata
)
{
    struct tally_dispatch *data = (struct tally_dispatch *) usr_data;

    const auto name_demangled = (data->demangle_name) ? f_demangle_name(name) : name;
    const auto name_with_metadata = (data->display_kernel_verbose && !strcmp(metadata, "")) ? name_demangled + "[" + metadata + "]" : name_demangled;

    TallyCoreTime a{dur, err};
    data->device[hpt_backend_function_name_dsd_t(hostname, vpid, vtid, backend, name_with_metadata, did, sdid)] += a;
}

void tally_traffic_usr_callback(
    struct common_data_s *common_data, void* usr_data, 
    const char* hostname, int64_t vpid, uint64_t vtid, int64_t ts,
    int64_t backend, const char* name, uint64_t size
)
{
    struct tally_dispatch *data = (struct tally_dispatch *) usr_data;

    TallyCoreByte a{(uint64_t)size, false};
    data->traffic[hpt_backend_function_name_t(hostname, vpid, vtid, backend, name)] += a;
}

void btx_register_usr_callbacks(name_to_dispatcher_t** name_to_dispatcher) {
    btx_register_callbacks_lttng_host(name_to_dispatcher, &tally_host_usr_callback);
    btx_register_callbacks_lttng_device(name_to_dispatcher, &tally_device_usr_callback);
    btx_register_callbacks_lttng_traffic(name_to_dispatcher, &tally_traffic_usr_callback);
}