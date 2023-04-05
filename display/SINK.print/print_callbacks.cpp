#include "component.h"
#include "dispatch.h"
#include "babeltrace2/babeltrace.h"

#include "tally.hpp"
#include "utils.hpp"


void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
    /* User allocates its own data structure */
    tally_data_t *data = new tally_data_t;
    /* User makes our API usr_data to point to his/her data structure */
    *usr_data = data;

    params_t *params = (params_t*) malloc(sizeof(params_t));
    btx_read_params(btx_handle, params);

    data->demangle_name = params->demangle_name;
    data->display_kernel_verbose = params->display_kernel_verbose;
    data->display_compact = params->display_compact;
    data->display_human = params->display_human;
    data->display_metadata = params->display_metadata;
    data->display_name_max_size = params->display_name_max_size;

    free(params);
}

void btx_finalize_usr_data(void *btx_handle, void *usr_data) {
    /* TODO: User need to cast the usr_data, we can avoid casting by wrapping this function
       and make the wrapper to do the casting for us.
    */
    tally_data_t *data = (tally_data_t *) usr_data;
    
    const int max_name_size = data->display_name_max_size;

    if (data->display_human) {
        if (data->display_metadata)
            print_metadata(data->metadata);

        if (data->display_compact) {

            for (const auto& [level,host]: data->host) {
                std::string s = join_iterator(data->host_backend_name[level]);
                print_compact(s, host,
                            std::make_tuple("Hostnames", "Processes", "Threads"),
                            max_name_size);
            }
            print_compact("Device profiling", data->device,
                            std::make_tuple("Hostnames", "Processes", "Threads",
                                            "Devices", "Subdevices"),
                            max_name_size);

            for (const auto& [level,traffic]: data->traffic) {
                std::string s = join_iterator(data->traffic_backend_name[level]);
                print_compact("Explicit memory traffic (" + s + ")", traffic,
                            std::make_tuple("Hostnames", "Processes", "Threads"),
                            max_name_size);
            }
        }else {
            for (const auto& [level,host]: data->host) {
                std::string s = join_iterator(data->host_backend_name[level]); 
                print_extended(s, host,
                            std::make_tuple("Hostname", "Process", "Thread"),
                            max_name_size);
            }
            print_extended("Device profiling", data->device,
                            std::make_tuple("Hostname", "Process", "Thread",
                                            "Device pointer", "Subdevice pointer"),
                            max_name_size);

            for (const auto& [level,traffic]: data->traffic) {
                std::string s = join_iterator(data->traffic_backend_name[level]);
                print_extended("Explicit memory traffic (" + s + ")", traffic,
                            std::make_tuple("Hostname", "Process", "Thread"),
                            max_name_size);
            }
        }
    } else {
        
        nlohmann::json j;
        j["units"] = {{"time", "ns"}, {"size", "bytes"}};
        
        if (data->display_metadata)
            j["metadata"] = data->metadata;
        
        if (data->display_compact) {
            for (auto& [level,host]: data->host)
                j["host"][level] = json_compact(host);

            if (!data->device.empty())
                j["device"] = json_compact(data->device);

            for (auto& [level,traffic]: data->traffic)
                j["traffic"][level] = json_compact(traffic);

        } else {
            for (auto& [level,host]: data->host)
                j["host"][level] = json_extented(host, std::make_tuple("Hostname", "Process", "Thread"));
                
            if (!data->device.empty())
                j["device"] = json_extented(data->device,std::make_tuple(
                    "Hostname", "Process","Thread", "Device pointer","Subdevice pointer"));

            for (auto& [level,traffic]: data->traffic)
                    j["traffic"][level] = json_extented(traffic,std::make_tuple(
                        "Hostname", "Process", "Thread"));
        }
        std::cout << j << std::endl;
    }

    /* De-allocate user data */
    delete data;
}

void aggreg_host_usr_callbacks(
    void *btx_handle, void *usr_data, const char* hostname, int64_t vpid, 
    uint64_t vtid, int64_t backend, const char* name, uint64_t dur, uint64_t min, 
    uint64_t max, uint64_t count, uint64_t err
)
{
    tally_data_t *data = (tally_data_t *) usr_data;

    TallyCoreTime a{dur, err, min, max, count};
    const int level = backend_level[backend];
    data->host_backend_name[level].insert(backend_name[backend]);
    data->host[level][hpt_function_name_t(hostname, vpid, vtid, name)] += a;
}

void aggreg_kernel_usr_callbacks(
    void *btx_handle, void *usr_data, const char* hostname, int64_t vpid,
    uint64_t vtid, int64_t backend, const char* name, const char* metadata, 
    uint64_t did, uint64_t sdid, uint64_t dur, uint64_t min, uint64_t max, 
    uint64_t count, uint64_t err
)
{
    tally_data_t *data = (tally_data_t *) usr_data;

    const auto name_demangled = (data->demangle_name) ? f_demangle_name(name) : name;
    const auto name_with_metadata = (data->display_kernel_verbose && !strcmp(metadata, "")) ? name_demangled + "[" + metadata + "]" : name_demangled;

    TallyCoreTime a{dur, err, min, max, count};
    data->device[hpt_device_function_name_t(hostname, vpid, vtid, did, sdid, name_with_metadata)] += a;
}

void aggreg_traffic_usr_callbacks(
    void *btx_handle, void *usr_data, const char* hostname, int64_t vpid,
    uint64_t vtid, int64_t backend, const char* name, uint64_t size, uint64_t min,
    uint64_t max, uint64_t count, uint64_t err
)
{
    tally_data_t *data = (tally_data_t *) usr_data;

    TallyCoreByte a{size, err, min, max, count};
    const int level = backend_level[backend];
    data->traffic_backend_name[level].insert(backend_name[backend]);
    data->traffic[level][hpt_function_name_t(hostname, vpid, vtid, name)] += a;
}

void lttng_device_name_usr_callbacks(
    void *btx_handle, void *usr_data, const char* hostname, int64_t vpid,
    uint64_t vtid, int64_t ts, int64_t backend, const char* name, uint64_t did
)
{
    tally_data_t *data = (tally_data_t *) usr_data;
    data->device_name[hp_device_t(hostname, vpid, did)] = name;
}

void lttng_ust_thapi_metadata_usr_callbacks(
    void *btx_handle, void *usr_data, const char* hostname, int64_t vpid,
    uint64_t vtid, int64_t ts, int64_t backend, const char* metadata
)
{
    tally_data_t *data = (tally_data_t *) usr_data;
    data->metadata.push_back(metadata);
} 

void btx_register_usr_callbacks(void *btx_handle) {
    btx_register_callbacks_aggreg_host(btx_handle,&aggreg_host_usr_callbacks);
    btx_register_callbacks_aggreg_kernel(btx_handle,&aggreg_kernel_usr_callbacks);
    btx_register_callbacks_aggreg_traffic(btx_handle,&aggreg_traffic_usr_callbacks);
    btx_register_callbacks_lttng_device_name(btx_handle,&lttng_device_name_usr_callbacks);
    btx_register_callbacks_lttng_ust_thapi_metadata(btx_handle,&lttng_ust_thapi_metadata_usr_callbacks);
}
