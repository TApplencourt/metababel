//! Backends' Messages Aggregation. 

//! This file contains the infraestructure used to aggregate data in lttng messages.

#include "component.h"
#include "dispatch.h"
#include "babeltrace2/babeltrace.h"

#include <unordered_map>
#include <tuple>
#include <regex>
#include <cmath> // isnan


// Datatypes represeting string classes (or messages) common data. 

typedef intptr_t        process_id_t;
typedef uintptr_t       thread_id_t;
typedef std::string     hostname_t;
typedef std::string     thapi_function_name;
typedef uintptr_t       thapi_device_id;
typedef uintptr_t       backend_t;
typedef std::string     device_metadata_t;

// Data structures used for aggregation.
typedef std::tuple<hostname_t, process_id_t, thread_id_t, backend_t, thapi_function_name> hpt_backend_function_name_t;
typedef std::tuple<hostname_t, process_id_t, thread_id_t, backend_t, thapi_function_name, thapi_device_id, thapi_device_id> hpt_backend_function_name_dsd_t;
typedef std::tuple<hostname_t, process_id_t, thread_id_t, backend_t, thapi_function_name, device_metadata_t, thapi_device_id, thapi_device_id> hpt_backend_function_name_meta_dsd_t;

// NOTE: Required to generate a hash of a tuple, otherwhise, the operaton "data->host[level][entity_id] += interval;"
// may fail since host[level] returns an unordered_map and this data structure does not know to hash a tuple.
// REFERENCE: https://stackoverflow.com/questions/7110301/generic-hash-for-tuples-in-unordered-map-unordered-set 
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

//! Returns a number as a string with the given number of decimals.
//! @param a_value the value to be casted to string with the given decimal places.
//! @param units units to be append at the end of the string.
//! @param n number of decimal places required.
//! REFERENCE: https://stackoverflow.com/questions/16605967/set-precision-of-stdto-string-when-converting-floating-point-values
template <typename T>
std::string to_string_with_precision(const T a_value, const std::string units, const int n = 2) {
  std::ostringstream out;
  out.precision(n);
  out << std::fixed << a_value << units;
  return out.str();
}

//! TallyCoreBase is a callbacks duration data collection and aggregation helper.
//! It is of interest to collect data for every (host,pid,tid,api_call_name) entity.
//! Since the same entity can take place several times, i.e., a thread spawned from 
//! a process running in a given host can call api_call_name several times, our 
//! interest is to aggregate these durations in a single one per entity.
//! In addition to the duration, othe data of interes is collected from different
//! ocurrences of the same entity such as, what was the minumum and max durations
//! among the ocurrences, the number of times an api_call_name happed for a given 
// "htp" (host,pid,tid), and how many occurrences failed.
//! Once the data of an entity is collected, when considering all its ocurrences,
//! This helper calls facilitates aggregation of data by overloading += and + operators.
class TallyCoreBase {
public:
  TallyCoreBase() {}

  TallyCoreBase(uint64_t _dur, bool _err) : duration{_dur}, error{_err} {
    count = 1;
    if (!error) {
      min = duration;
      max = duration;
    } else
      duration = 0;
  }

  //! Total exeuction time 
  //! The sum of the durations of traces of an specific entity (host,proces,thread,api_call_name), 
  // it is ("Time" in statistics)
  uint64_t duration{0};
  
  //! Accumulates the amount of errors found for an (host,pid,tid,api_call_name) entity.
  uint64_t error{0};

  //! Minimum duration found among occurrences of the same (host,pid,tid,api_call_name) entity.
  uint64_t min{std::numeric_limits<uint64_t>::max()};

  //! Maximum duration found among occurrences of the same (host,pid,tid,api_call_name) entity.
  uint64_t max{0};

  //! Count the number of times an error is found for a given (host,pid,tid,api_call_name) entity.
  uint64_t count{0};

  //! Percentage of the total execution time.
  //! duration / app_total_execution_time, this is computed at the end, once we have collected 
  //! the duratiin information of all the ocurrences of a given (host,pid,tid,api_call_name) entity.
  double duration_ratio{1.};

  //! Average duration.
  //! It is rougly duration / #of_sucessfull_calls, see "finalize" member function.
  double average{0};

  //! Accumulates duration information.
  TallyCoreBase &operator+=(const TallyCoreBase &rhs) {
    this->duration += rhs.duration;
    this->min = std::min(this->min, rhs.min);
    this->max = std::max(this->max, rhs.max);
    this->count += rhs.count;
    this->error += rhs.error;
    return *this;
  }

  //! Updates the average and duration ratio.
  //! NOTE: This should happend once we have collected the information the duratiin information 
  //! of all the ocurrences of a given (host,pid,tid,api_call_name) entity.
  void finalize(const TallyCoreBase &rhs) {
    average = ( count && count != error ) ? static_cast<double>(duration) / (count-error) : 0.;
    duration_ratio = static_cast<double>(duration) / rhs.duration;
  }

  //! Enables the comparison of two TallyCoreBase instances by their duration.
  //! It is used for sorting purposes.
  bool operator>(const TallyCoreBase &rhs) { return duration > rhs.duration; }
};

//! Specifalization of TallyCoreBase for execution times.
class TallyCoreTime : public TallyCoreBase {
  // Printing related functions were moved to SINK.print

  public:
    using TallyCoreBase::TallyCoreBase;
};

//! Specialization of TallyCoreBase for data transfer sizes.
//! This is used for traffic related events, lttng:traffic.
class TallyCoreByte : public TallyCoreBase {
  // Printing related functions were moved to SINK.print

  public:
    using TallyCoreBase::TallyCoreBase;
};

struct aggreg_data_s {
  std::unordered_map<hpt_backend_function_name_t, TallyCoreTime> host;
  std::unordered_map<hpt_backend_function_name_meta_dsd_t, TallyCoreTime> device;
  std::unordered_map<hpt_backend_function_name_t, TallyCoreByte> traffic;
};

typedef struct aggreg_data_s aggreg_data_t;
