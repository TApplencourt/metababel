/* Code generated headers */
#include "component.h"
#include "dispatch.h"
#include <babeltrace2/babeltrace.h>

/* User specific headers */
#include <iostream>
#include <stdint.h>
#include <limits>
#include <set>
#include <string>
#include <tuple>
#include <map>
#include <unordered_map>
#include <math.h>

#include "tabulate.hpp"


/**
 * NOTE: Required to generate a hash of a tuple, otherwhise, the operaton "data->host[level][entity_id] += interval;"
 * may fail since host[level] returns an unordered_map and this data structure does not know to hash a tuple.
 * Reference: https://stackoverflow.com/questions/7110301/generic-hash-for-tuples-in-unordered-map-unordered-set 
*/
namespace std{
    namespace
    {
        // Code from boost
        // Reciprocal of the golden ratio helps spread entropy
        //     and handles duplicates.
        // See Mike Seymour in magic-numbers-in-boosthash-combine:
        //     https://stackoverflow.com/questions/4948780
        template <class T>
        inline void hash_combine(std::size_t& seed, T const& v)
        {
            seed ^= hash<T>()(v) + 0x9e3779b9 + (seed<<6) + (seed>>2);
        }

        // Recursive template code derived from Matthieu M.
        template <class Tuple, size_t Index = std::tuple_size<Tuple>::value - 1>
        struct HashValueImpl
        {
          static void apply(size_t& seed, Tuple const& tuple)
          {
            HashValueImpl<Tuple, Index-1>::apply(seed, tuple);
            hash_combine(seed, get<Index>(tuple));
          }
        };

        template <class Tuple>
        struct HashValueImpl<Tuple,0>
        {
          static void apply(size_t& seed, Tuple const& tuple)
          {
            hash_combine(seed, get<0>(tuple));
          }
        };
    }

    template <typename ... TT>
    struct hash<std::tuple<TT...>>
    {
        size_t
        operator()(std::tuple<TT...> const& tt) const
        {
            size_t seed = 0;
            HashValueImpl<std::tuple<TT...> >::apply(seed, tt);
            return seed;
        }

    };

    template <typename ... TT>
    struct hash<std::pair<TT...>>
    {
        size_t
     
   operator()(std::pair<TT...> const& tt) const
        {
            size_t seed = 0;
            HashValueImpl<std::pair<TT...> >::apply(seed, tt);
            return seed;
        }

    };
}

/* Devices ids as identified when lttng event messages (tracepoints) are generated */
enum BACKEND_ID_e { 
    BACKEND_UNKNOWN = 0,
    BACKEND_ZE = 1,
    BACKEND_OPENCL = 2,
    BACKEND_CUDA = 3,
    BACKEND_OMP_TARGET_OPERATIONS = 4,
    BACKEND_OMP = 5 
};

/* TODO */
constexpr int BACKEND_LEVEL[] = { 
    2, // BACKEND_UNKNOWN
    2, // BACKEND_ZE
    2, // BACKEND_OPENCL
    2, // BACKEND_CUDA
    1, // BACKEND_OMP_TARGET_OPERATIONS
    0  // BACKEND_OMP
};

/* Backend names match with "BACKEND_ID_e" in the same order */
constexpr const char* BACKEND_NAME[] = { 
    "BACKEND_UNKNOWN",
    "BACKEND_ZE",
    "BACKEND_OPENCL",
    "BACKEND_CUDA",
    "BACKEND_OMP_TARGET_OPERATIONS",
    "BACKEND_OMP" 
};

/* Datatype for the ame of the host that generates a trace message */
typedef std::string hostname_t;

/* Datatype for the process id in a host that generates a trace message */
typedef intptr_t process_id_t;

/* Datatype for the thread id in host-process that generates a trace message */
typedef uintptr_t thread_id_t;

/* Datatype for the name used to identify the specific backend API call invoked 
and referenced in a trace message */
typedef std::string thapi_function_name;

/* Datatype to identify a specific entity (host,process,thread,api_call_name) that invoke a backend 
API call, which is translated to a trace message */
typedef std::tuple<hostname_t, process_id_t, thread_id_t, thapi_function_name> hpt_function_name_t;


/**
 * Since a give backend API call such as "clGetDeviceInfo" can be called several times,
 * and a trace interval message is generated for every call. This class works as a helper
 * to accumulate the duration and other statistics of a given entity (host,process,thread,api_call_name). 
*/
class CoreTime
{
    public:

        //! Total exeuction time 
        /*! The sum of the durations of traces of an specific entity (host,proces,thread,api_call_name), 
        it is ("Time" in statistics) */
        uint64_t duration{0};

        //! Percentage of the total execution time.
        /*! duration / app_total_execution_time */
        double duration_ratio{1.};

        //! Average duration among traces of the same type.
        double duration_average{0.};

        //! Entity minimun duration
        uint64_t duration_min{std::numeric_limits<uint64_t>::max()};

        //! Entity maximum duration
        uint64_t duration_max{0};

        //! Coount the number of times a given interval id (host,pid,tid,call_name) is called 
        uint64_t calls_count{1};

        //! Accumulates the amount of errors reported by an entity.
        uint64_t error_count{0};

        CoreTime(){}

        //! Initialize
        /*!
        \param _dur entity duration.
        \param _err right hand side object.
        \return The left hand side (lhs) object updated.
        */
        CoreTime(uint64_t _dur, uint64_t _err): duration{_dur}, error_count{_err}
        {
            // If an error is reported for a given interval  
            // the duration for that interval_id is set to 0. 
            this->duration_min = this->error_count ? 0 : this->duration;
            this->duration_max = this->error_count ? 0 : this->duration;
        }

        //! Update this object statistics.
        /*! Update this objetc statistics using 
        information in the right hand side object. 
        \param rhs right hand side object.
        \return The left hand side (lhs) object updated.
        */
        CoreTime &operator+=(const CoreTime &rhs) 
        {
            this->duration += rhs.duration;
            this->duration_min = std::min(this->duration_min, rhs.duration_min);
            this->duration_max = std::max(this->duration_max, rhs.duration_max);
            this->calls_count += rhs.calls_count;
            this->error_count += rhs.error_count;
            return *this;
        }

        CoreTime &operator+(const CoreTime &rhs) 
        {
            this->duration += rhs.duration;
            // We can't sum averages and compute a new average from the sum.
            this->duration_average = NAN;
            this->duration_ratio = rhs.duration_ratio;
            this->duration_min = std::min(this->duration_min, rhs.duration_min);
            this->duration_max = std::max(this->duration_max, rhs.duration_max);
            this->calls_count += rhs.calls_count;
            this->error_count += rhs.error_count;
            return *this;
        }

        void update_duration_ratio(double denominator)
        {
            this->duration_ratio = this->duration / denominator;
        }

        void update_duration_average()
        {
            bool condition = ( this->calls_count && this->calls_count != this->error_count );
            this->duration_average = condition ? static_cast<double>(this->duration) / ( this->calls_count - this->error_count ) : NAN ;
        }
};


/**
 * Struct to be defined by the user according to the 
 * information hes/she intends to collect from event
 * messages.
*/
struct statistics_s {

    /*! Maps "level" with a set that holds the backend names identified in an specific level. */ 
    std::map<unsigned, std::set<const char*>> host_backend_name;

    /**
     * Maps the backend_level to another another unordered_map. The unordered_map (hash table) 
     * associates a tuple "hpt_function_name(hostname_t, process_id_t, thread_id_t, thapi_function_name)"
     * servig as a unique key to an specific TallyCoreTime object.
    */
    std::map<unsigned,std::unordered_map<hpt_function_name_t, CoreTime>> host;

    
};


// CoreTime accumulate(std::unordered_map<hpt_function_name_t,CoreTime> umap)
// {    
//     CoreTime result;
//     for(const auto& [key,value] : umap) 
//         result += value;
//     return result;

//     // Reduce implementation takes roughly twice more than iteration
//     // std::pair<hpt_function_name_t,CoreTime> initValue;
//     // std::pair<hpt_function_name_t,CoreTime> finalValue = std::accumulate( 
//     //     umap.begin(),
//     //     umap.end(),
//     //     initValue, 
//     //     [](std::pair<hpt_function_name_t,CoreTime> a, std::pair<hpt_function_name_t,CoreTime> b){ return std::pair<hpt_function_name_t,CoreTime>( a.first, (a.second + b.second) ) ; });
//     // return finalValue.second;
// }

hpt_function_name_t 
apply_mask(hpt_function_name_t identifier, bool mask[])
{
    hpt_function_name_t result{"",0,0,""};
    std::get<0>(result) = mask[0] ? std::get<0>(identifier) : std::get<0>(result);
    std::get<1>(result) = mask[1] ? std::get<1>(identifier) : std::get<1>(result);
    std::get<2>(result) = mask[2] ? std::get<2>(identifier) : std::get<2>(result);
    std::get<3>(result) = mask[3] ? std::get<3>(identifier) : std::get<3>(result);

    return result;
}

std::unordered_map<hpt_function_name_t,CoreTime>
accumulate_by_fields(std::unordered_map<hpt_function_name_t,CoreTime> umap, bool mask[], unsigned *counter)
{
    std::set<hostname_t> hostnames;
    std::set<process_id_t> processes;
    std::set<thread_id_t> threads;
    std::set<thapi_function_name> funct_names; 

    std::unordered_map<hpt_function_name_t,CoreTime> aggregation;

    for(const auto& [key,value] : umap)
    {
        // Aggregating data
        hpt_function_name_t new_key = apply_mask(key,mask);
        aggregation[new_key] += value;

        // Counting 
        hostnames.insert(std::get<0>(key));
        processes.insert(std::get<1>(key));
        threads.insert(std::get<2>(key));
        funct_names.insert(std::get<3>(key));
    }

    *(counter + 0) = hostnames.size();
    *(counter + 1) = processes.size();
    *(counter + 2) = threads.size();
    *(counter + 3) = funct_names.size();

    return aggregation;
}


