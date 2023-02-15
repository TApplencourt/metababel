#include "component.h"
#include "dispatch.h"

//=> filename: tally.hpp
//#include "xprof_utils.hpp"
//#include "tally_utils.hpp"
#include  <map>
#include  <unordered_map>

//=> filename: xprof_utils.hpp
#include <map>
#include <tuple>
#include <string>
#include "babeltrace2/babeltrace.h"

//=> filename: tally_utils.hpp
#include <set>
#include <vector>
#include <cmath>
#include <string>
#include <iostream>
#include <iomanip>

//=> filename: xprof_utils.hpp
enum backend_e{ BACKEND_UNKNOWN = 0,
                BACKEND_ZE = 1,
                BACKEND_OPENCL = 2,
                BACKEND_CUDA = 3,
                BACKEND_OMP_TARGET_OPERATIONS = 4,
                BACKEND_OMP = 5 };

constexpr int backend_level[] = { 2, 2, 2, 2, 1, 0 };

constexpr const char* backend_name[] = { "BACKEND_UNKNOWN",
                "BACKEND_ZE",
                "BACKEND_OPENCL",
                "BACKEND_CUDA",
                "BACKEND_OMP_TARGET_OPERATIONS",
                "BACKEND_OMP" };

typedef enum backend_e backend_t;

typedef intptr_t                       process_id_t;
typedef uintptr_t                      thread_id_t;
typedef std::string                    hostname_t;
typedef std::string                    thapi_function_name;
typedef uintptr_t                      thapi_device_id;

// Represent a device and a sub device
typedef std::tuple<thapi_device_id, thapi_device_id> dsd_t;
typedef std::tuple<hostname_t, thapi_device_id> h_device_t;
typedef std::tuple<hostname_t, process_id_t> hp_t;
typedef std::tuple<hostname_t, process_id_t, thread_id_t> hpt_t;
typedef std::tuple<hostname_t, process_id_t, thread_id_t, thapi_function_name> hpt_function_name_t;
typedef std::tuple<thread_id_t, thapi_function_name> t_function_name_t;
typedef std::tuple<hostname_t, process_id_t, thread_id_t, thapi_device_id, thapi_device_id> hpt_dsd_t;
typedef std::tuple<hostname_t, process_id_t, thread_id_t, thapi_device_id, thapi_device_id, thapi_function_name> hpt_device_function_name_t;
typedef std::tuple<hostname_t, process_id_t, thapi_device_id> hp_device_t;
typedef std::tuple<hostname_t, process_id_t, thapi_device_id, thapi_device_id> hp_dsd_t;

typedef std::tuple<long,long> sd_t;
typedef std::tuple<thread_id_t, thapi_function_name, long> tfn_ts_t;
typedef std::tuple<thapi_function_name, long> fn_ts_t;
typedef std::tuple<thapi_function_name, thapi_device_id, thapi_device_id, long> fn_dsd_ts_t;
typedef std::tuple<thread_id_t, thapi_function_name, thapi_device_id, thapi_device_id, long> tfn_dsd_ts_t;

typedef std::tuple<thapi_function_name, std::string, thapi_device_id, thapi_device_id, long> fnm_dsd_ts_t;
typedef std::tuple<thread_id_t, thapi_function_name, std::string, thapi_device_id, thapi_device_id, long> tfnm_dsd_ts_t;

// https://stackoverflow.com/questions/7110301/generic-hash-for-tuples-in-unordered-map-unordered-set
// Hash of std tuple
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

template <typename T>
std::string to_string_with_precision(const T a_value, const std::string units,
                                     const int n = 2) {
  std::ostringstream out;
  out.precision(n);
  out << std::fixed << a_value << units;
  return out.str();
}

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

  uint64_t duration{0};
  uint64_t error{0};
  uint64_t min{std::numeric_limits<uint64_t>::max()};
  uint64_t max{0};
  uint64_t count{0};
  double duration_ratio{1.};
  double average{0};

  // Pure virtual function is needed if not we have an
  // ` symbol lookup error: ./ici/lib/libXProf.so: undefined symbol: _ZTI13TallyCoreBase`
  virtual const std::vector<std::string> to_string() = 0;

  const auto to_string_size() {
    std::vector<long> v;
    for (auto &e : to_string())
      v.push_back(static_cast<long>(e.size()));
    return v;
  }

  TallyCoreBase &operator+=(const TallyCoreBase &rhs) {
    this->duration += rhs.duration;
    this->min = std::min(this->min, rhs.min);
    this->max = std::max(this->max, rhs.max);
    this->count += rhs.count;
    this->error += rhs.error;
    return *this;
  }

  void finalize(const TallyCoreBase &rhs) {
    average = ( count && count != error ) ? static_cast<double>(duration) / (count-error) : 0.;
    duration_ratio = static_cast<double>(duration) / rhs.duration;
  }

  bool operator>(const TallyCoreBase &rhs) { return duration > rhs.duration; }

  void update_max_size(std::vector<long> &m) {
    const auto current_size = to_string_size();
    for (auto i = 0U; i < current_size.size(); i++)
      m[i] = std::max(m[i], current_size[i]);
  }
};

class TallyCoreTime : public TallyCoreBase {
public:
  static constexpr std::array headers{"Time", "Time(%)", "Calls", "Average", "Min", "Max", "Error"};

  using TallyCoreBase::TallyCoreBase;
  virtual const std::vector<std::string> to_string() {
    return std::vector<std::string>{format_time(duration),
                                    std::isnan(duration_ratio) ? "" : to_string_with_precision(100. * duration_ratio, "%"),
                                    to_string_with_precision(count, "", 0),
                                    format_time(average),
                                    format_time(min),
                                    format_time(max),
                                    to_string_with_precision(error, "", 0)};
  }

private:
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

class TallyCoreByte : public TallyCoreBase {
public:
  static constexpr std::array headers{"Byte", "Byte(%)", "Calls", "Average", "Min", "Max", "Error"};

  using TallyCoreBase::TallyCoreBase;
  virtual const std::vector<std::string> to_string() {
    return std::vector<std::string>{format_byte(duration),
                                    to_string_with_precision(100. * duration_ratio, "%"),
                                    to_string_with_precision(count, "", 0),
                                    format_byte(average),
                                    format_byte(min),
                                    format_byte(max),
                                    to_string_with_precision(error, "", 0)};
  }

private:
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


//=> filename: tally.hpp
/* Sink component's private data */
struct tally_dispatch {
    bool display_compact;
    bool demangle_name;
    bool display_human;
    bool display_metadata;
    int  display_name_max_size;
    bool display_kernel_verbose;

    std::map<unsigned,std::set<const char*>> host_backend_name;
    std::map<unsigned,std::unordered_map<hpt_function_name_t, TallyCoreTime>> host;

    std::unordered_map<hpt_device_function_name_t, TallyCoreTime> device;

    std::map<unsigned,std::set<const char*>> traffic_backend_name;
    std::map<unsigned,std::unordered_map<hpt_function_name_t, TallyCoreByte>> traffic;

    std::unordered_map<hp_device_t, std::string> device_name;
    std::vector<std::string> metadata;
};