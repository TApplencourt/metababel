#include "my_callbacks.hpp"
#include <chrono>

using namespace std::chrono;

void btx_initialize_usr_data(common_data_t *common_data, void **usr_data) {
    /* User allocates its own data structure */
    struct tally_dispatch *data = new struct tally_dispatch;
    /* User makes our API usr_data to point to his/her data structure */
    *usr_data = data;

    std::cout  << "Initialized" << std::endl;
}

void btx_finalize_usr_data(common_data_t *common_data, void *usr_data) {
    /* User cast the API usr_data that was already initialized with his/her data */
    struct tally_dispatch *data = (struct tally_dispatch *) usr_data;
    /* User do some stuff with the saved data */
    // do something....

    // Use auto keyword to avoid typing long
    // type definitions to get the timepoint
    // at this instant use function now()
    auto start = high_resolution_clock::now();

    // unsigned level = 2;
    // auto backends = data->host_backend_name[level];
    // auto hosts = data->host[level];

    // bool mask[4] = {1,1,1,1};
    // unsigned count[] = {0,0,0,0};

    // auto result = accumulate_by_fields(hosts,mask,count);
    // std::vector<std::string> header_1 = {"Hostnames","Processes","Threads","Names"};
    // display_header(backends,header_1,count,4);

    // std::vector<std::string> header_2 = {"Host","Pid","Tid","Name","Time", "Time(%)", "Calls", "Average", "Min", "Max", "Error"};
    // display_table(header_2,result);

    auto stop = high_resolution_clock::now();

    // Subtract stop and start timepoints and
    // cast it to required unit. Predefined units
    // are nanoseconds, microseconds, milliseconds,
    // seconds, minutes, hours. Use duration_cast()
    // function.
    auto duration = duration_cast<microseconds>(stop - start);

    // To get the value of duration use the count()
    // member function on the duration object
    std::cout << "------------------" << std::endl;
    std::cout << "Execution Time (us):" << duration.count() << std::endl;

    /* Use has to deallocate the memory he/she requested for his/her data structure */
    delete data;

    std::cout  << "Finalized" << std::endl;
}

static void lttng_host_usr_callback(
    struct common_data_s *common_data, void *usr_data,   const char* hostname,
    int64_t vpid, uint64_t vtid, int64_t ts, int64_t backend_id, const char* name,
    uint64_t dur, bt_bool err
) 
{
    std::cout  << "lttng_host_usr_callback" << std::endl;
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
    uint64_t did, uint64_t sdid, bt_bool err
)
{
    std::cout  << "lttng_device_usr_callback" << std::endl;


}

// static void lttng_traffic_usr_callback(
//     common_data_t *common_data, void *usr_data, const char* hostname, int64_t vpid, 
//     uint64_t vtid, int64_t ts, int64_t backend ,const char* name, uint64_t dur, bt_bool err
// )
// {


// }

static void lttng_traffic_usr_callback(
    common_data_t *common_data, void *usr_data, const char* hostname,
    int64_t vpid, uint64_t vtid, int64_t ts, int64_t backend, 
    const char* name, uint64_t size

)
{
    std::cout  << "lttng_traffic_usr_callback" << std::endl;
}

static void lttng_device_name_usr_callback(
    common_data_t *common_data, void *usr_data, const char* hostname, int64_t vpid,
    uint64_t vtid, int64_t ts, int64_t backend, const char* name, uint64_t did
)
{
    std::cout  << "lttng_device_name_usr_callback" << std::endl;
}

void btx_register_usr_callbacks(name_to_dispatcher_t** name_to_dispatcher) {
    btx_register_callbacks_lttng_host(name_to_dispatcher, &lttng_host_usr_callback);
    btx_register_callbacks_lttng_device(name_to_dispatcher, &lttng_device_usr_callback);
    btx_register_callbacks_lttng_traffic(name_to_dispatcher, &lttng_traffic_usr_callback);
    btx_register_callbacks_lttng_device_name(name_to_dispatcher, &lttng_device_name_usr_callback);
}