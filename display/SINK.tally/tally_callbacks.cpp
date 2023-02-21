#include "tally_callbacks.hpp"
#include <chrono>

using namespace std::chrono;

void btx_initialize_usr_data(common_data_t *common_data, void **usr_data) {
    /* User allocates its own data structure */
    struct tally_dispatch *data = new struct tally_dispatch;
    /* User makes our API usr_data to point to his/her data structure */
    *usr_data = data;

    params_t *params = (params_t*) malloc(sizeof(params_t));
    btx_read_params(common_data, params);

    data->display_compact = params->display_compact;
    data->demangle_name = params->demangle_name;
    data->display_human = params->display_human;
    data->display_metadata = params->display_metadata;
    data->display_name_max_size = params->display_name_max_size;
    data->display_kernel_verbose = params->display_kernel_verbose;

    free(params);

    printf("PRINTING PARAMS FROM SINK...\n");
    printf("PARAM display_compact: %s\n", data->display_compact ? "true" : "false");
    printf("PARAM demangle_name: %s\n", data->demangle_name ? "true" : "false");
    printf("PARAM display_human: %s\n", data->display_human ? "true" : "false");
    printf("PARAM display_metadata: %s\n", data->display_metadata ? "true" : "false");
    printf("PARAM display_name_max_size: %d\n", data->display_name_max_size);
    printf("PARAM display_kernel_verbose: %s\n", data->display_kernel_verbose ? "true" : "false");

}

void btx_finalize_usr_data(common_data_t *common_data, void *usr_data) {
    /* User cast the API usr_data that was already initialized with his/her data */
    struct tally_dispatch *data = (struct tally_dispatch *) usr_data;
    
    /* User do some stuff with the saved data */

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

    /* Desolate user data */
    delete data;
}

static void lttng_host_usr_callback(
    struct common_data_s *common_data, void *usr_data,   const char* hostname,
    int64_t vpid, uint64_t vtid, int64_t ts, int64_t backend_id, const char* name,
    uint64_t dur, bt_bool err
) 
{
    /* In callbacks, the user just  need to cast our API usr_data to his/her data structure */
    struct tally_dispatch *data = (struct tally_dispatch *) usr_data;

    TallyCoreTime a{dur, err};
    const int level = backend_level[backend_id];
    data->host_backend_name[level].insert(backend_name[backend_id]);
    data->host[level][hpt_function_name_t(hostname, vpid, vtid, name)] += a;
}

static void lttng_device_usr_callback(
    common_data_t *common_data, void *usr_data, const char* hostname, int64_t vpid,
    uint64_t vtid, int64_t ts, int64_t backend, const char* name, uint64_t dur, 
    uint64_t did, uint64_t sdid, bt_bool err, const char* metadata
)
{
    /* In callbacks, the user just  need to cast our API usr_data to his/her data structure */
    struct tally_dispatch *data = (struct tally_dispatch *) usr_data;

    /* TODO: Should fucking cache this function */
    const auto name_demangled = (data->demangle_name) ? f_demangle_name(name) : name;
    const auto name_with_metadata = (data->display_kernel_verbose && !strcmp(metadata, "")) ? name_demangled + "[" + metadata + "]" : name_demangled;

    TallyCoreTime a{dur, err};
    data->device[hpt_device_function_name_t(hostname, vpid, vtid, did, sdid, name_with_metadata)] += a;

}

static void lttng_traffic_usr_callback(
    common_data_t *common_data, void *usr_data, const char* hostname,
    int64_t vpid, uint64_t vtid, int64_t ts, int64_t backend, 
    const char* name, uint64_t size

)
{
    /* In callbacks, the user just  need to cast our API usr_data to his/her data structure */
    struct tally_dispatch *data = (struct tally_dispatch *) usr_data;

    TallyCoreByte a{(uint64_t)size, false};
    const int level = backend_level[backend];
    data->traffic_backend_name[level].insert(backend_name[backend]);
    data->traffic[level][hpt_function_name_t(hostname, vpid, vtid, name)] += a;
}

static void lttng_device_name_usr_callback(
    common_data_t *common_data, void *usr_data, const char* hostname, int64_t vpid,
    uint64_t vtid, int64_t ts, int64_t backend, const char* name, uint64_t did
)
{
    /* In callbacks, the user just  need to cast our API usr_data to his/her data structure */
    struct tally_dispatch *data = (struct tally_dispatch *) usr_data;

    data->device_name[hp_device_t(hostname, vpid, did)] = name;
}

static void lttng_thapi_metadata_usr_callback(
    common_data_t *common_data, void *usr_data,const char* hostname, int64_t vpid,
    uint64_t vtid, int64_t ts, int64_t backend, const char* metadata
)
{
    /* In callbacks, the user just  need to cast our API usr_data to his/her data structure */
    struct tally_dispatch *data = (struct tally_dispatch *) usr_data;

    data->metadata.push_back(metadata);
}

void btx_register_usr_callbacks(name_to_dispatcher_t** name_to_dispatcher) {
    btx_register_callbacks_lttng_host(name_to_dispatcher, &lttng_host_usr_callback);
    btx_register_callbacks_lttng_device(name_to_dispatcher, &lttng_device_usr_callback);
    btx_register_callbacks_lttng_traffic(name_to_dispatcher, &lttng_traffic_usr_callback);
    btx_register_callbacks_lttng_device_name(name_to_dispatcher, &lttng_device_name_usr_callback);
    btx_register_callbacks_lttng_ust_thapi_metadata(name_to_dispatcher, &lttng_thapi_metadata_usr_callback);
}