//! Backends' Messages Tabulation and Summarization (tally). 

//! This file contains the infraestructure used to tabulate data 
//! in messages that were generated from different backends.

#include "component.h"
#include "dispatch.h"
#include "babeltrace2/babeltrace.h"

#include <unordered_map>
#include <tuple>
#include <regex>
#include <cmath> // isnan

#include "my_demangle.h"


// Datatypes represeting string classes (or messages) common data. 

typedef intptr_t        process_id_t;
typedef uintptr_t       thread_id_t;
typedef std::string     hostname_t;
typedef std::string     thapi_function_name;
typedef uintptr_t       thapi_device_id;
typedef uintptr_t       backend_t;

// Data strcutures just for aggregation
typedef std::tuple<hostname_t, process_id_t, thread_id_t, backend_t, thapi_function_name> hpt_backend_function_name_t;
typedef std::tuple<hostname_t, process_id_t, thread_id_t, backend_t, thapi_function_name, thapi_device_id, thapi_device_id> hpt_backend_function_name_dsd_t;

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

//! Returns a demangled name.
//! @param mangle_name function names
thapi_function_name f_demangle_name(thapi_function_name mangle_name) {
  std::string result = mangle_name;
  std::string line_num;

  // C++ don't handle PCRE, hence and lazy/non-greedy and $.
  const static std::regex base_regex("__omp_offloading_[^_]+_[^_]+_(.*?)_([^_]+)$");
  std::smatch base_match;
  if (std::regex_match(mangle_name, base_match, base_regex) && base_match.size() == 3) {
    result = base_match[1].str();
    line_num = base_match[2].str();
  }

  const char *demangle = my_demangle(result.c_str());
  if (demangle) {
    thapi_function_name s{demangle};
    if (!line_num.empty())
       s += "_" + line_num;

    /* We name the kernels after the type that gets passed in the first
       template parameter to the sycl_kernel function in order to prevent
       it from conflicting with any actual function name.
       The result is the demangling will always be something like, “typeinfo for...”.
    */
    if (s.rfind("typeinfo name for ") == 0)
      return s.substr(18, s.size());
    return s;
  }
  return mangle_name;
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

  // NOTE: Pure virtual function is needed if not we have an
  //`symbol lookup error: ./ici/lib/libXProf.so: undefined symbol: _ZTI13TallyCoreBase`
  virtual const std::vector<std::string> to_string() = 0;

  const auto to_string_size() {
    std::vector<long> v;
    for (auto &e : to_string())
      v.push_back(static_cast<long>(e.size()));
    return v;
  }

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

  void update_max_size(std::vector<long> &m) {
    const auto current_size = to_string_size();
    for (auto i = 0U; i < current_size.size(); i++)
      m[i] = std::max(m[i], current_size[i]);
  }
};

//! Specifalization of TallyCoreBase for execution times.
class TallyCoreTime : public TallyCoreBase {
public:
  static constexpr std::array headers{"Time", "Time(%)", "Calls", "Average", "Min", "Max", "Error"};

  using TallyCoreBase::TallyCoreBase;
  virtual const std::vector<std::string> to_string() {
    return std::vector<std::string>{
      format_time(duration),
      std::isnan(duration_ratio) ? "" : to_string_with_precision(100. * duration_ratio, "%"),
      to_string_with_precision(count, "", 0),
      format_time(average),
      format_time(min),
      format_time(max),
      to_string_with_precision(error, "", 0)
    };
  }

private:
  //! Returns duration as a formated string with units.
  template <typename T>
  std::string format_time(const T duration) {
    if (duration == std::numeric_limits<T>::max() || duration == T{0})
        return "";

    const double h = duration / 3.6e+12;
    if (h >= 1.)
      return to_string_with_precision(h, "h");

    const double min = duration / 6e+10;
    if (min >= 1.)
      return to_string_with_precision(min, "min");

    const double s = duration / 1e+9;
    if (s >= 1.)
      return to_string_with_precision(s, "s");

    const double ms = duration / 1e+6;
    if (ms >= 1.)
      return to_string_with_precision(ms, "ms");

    const double us = duration / 1e+3;
    if (us >= 1.)
      return to_string_with_precision(us, "us");

    return to_string_with_precision(duration, "ns");
  }
};

//! Specialization of TallyCoreBase for data transfer sizes.
//! This is used for traffic related events, lttng:traffic.
class TallyCoreByte : public TallyCoreBase {
public:
  static constexpr std::array headers{"Byte", "Byte(%)", "Calls", "Average", "Min", "Max", "Error"};

  using TallyCoreBase::TallyCoreBase;
  virtual const std::vector<std::string> to_string() {
    return std::vector<std::string>{
      format_byte(duration),
      to_string_with_precision(100. * duration_ratio, "%"),
      to_string_with_precision(count, "", 0),
      format_byte(average),
      format_byte(min),
      format_byte(max),
      to_string_with_precision(error, "", 0)
    };
  }

private:

  //! Returns a data transfer size (duration) as a formated string with units.
  template <typename T> std::string format_byte(const T duration) {
    const double PB = duration / 1e+15;
    if (PB >= 1.)
      return to_string_with_precision(PB, "PB");

    const double TB = duration / 1e+12;
    if (TB >= 1.)
      return to_string_with_precision(TB, "TB");

    const double GB = duration / 1e+9;
    if (GB >= 1.)
      return to_string_with_precision(GB, "GB");

    const double MB = duration / 1e+6;
    if (MB >= 1.)
      return to_string_with_precision(MB, "MB");

    const double kB = duration / 1e+3;
    if (kB >= 1.)
      return to_string_with_precision(kB, "kB");

    return to_string_with_precision(duration, "B");
  }
};

struct tally_dispatch {
  bool demangle_name;  
  bool display_kernel_verbose;
  std::unordered_map<hpt_backend_function_name_t, TallyCoreTime> host;
  std::unordered_map<hpt_backend_function_name_dsd_t, TallyCoreTime> device;
  std::unordered_map<hpt_backend_function_name_t, TallyCoreByte> traffic;
};
