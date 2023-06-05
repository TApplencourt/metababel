#include <assert.h>
#include <metababel/metababel.h>

#include "callbacks.hpp"

/* hashes do not work properly for std::string that's why const char */
typedef const char *hostname_t;
typedef intptr_t process_id_t;
typedef uintptr_t thread_id_t;
typedef uint64_t timestamp_t;
typedef uint64_t backend_t;

typedef std::string thapi_function_name_t;
typedef uint64_t dur_t;
typedef bt_bool err_t;

typedef std::tuple<hostname_t, process_id_t, thread_id_t> hpt_backend_t;

struct data_s {
  std::map<hpt_backend_t, timestamp_t> dispatch;
};

typedef struct data_s data_t;

void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
  data_t *data = new data_t;
  *usr_data = data;
}

void btx_finalize_usr_data(void *btx_handle, void *usr_data) {
  data_t *data = (data_t *)usr_data;
  delete data;
}

static void btx_hip_entry_matcher(void *btx_handle, void *usr_data, const char *stream_class_name,
                                  const char *event_class_name, bool *matched, int64_t timestamp,
                                  int64_t vpid, uint64_t vtid) {
  data_t *data = (data_t *)usr_data;
  *matched = strstr(event_class_name, "_entry") != NULL;
}

static void btx_hip_entry_callback(void *btx_handle, void *usr_data, const char *stream_class_name,
                                   const char *event_class_name, int64_t timestamp, int64_t vpid,
                                   uint64_t vtid) {
  data_t *data = (data_t *)usr_data;
  data->dispatch[hpt_backend_t("host", vpid, vtid)] = timestamp;
}

static void btx_hip_exit_matcher(void *btx_handle, void *usr_data, const char *stream_class_name,
                                 const char *event_class_name, bool *matched, int64_t timestamp,
                                 int64_t vpid, uint64_t vtid) {
  data_t *data = (data_t *)usr_data;
  *matched = strstr(event_class_name, "_exit") != NULL;
}

static void btx_hip_exit_callback(void *btx_handle, void *usr_data, const char *stream_class_name,
                                  const char *event_class_name, int64_t timestamp, int64_t vpid,
                                  uint64_t vtid) {
  data_t *data = (data_t *)usr_data;

  int64_t hipResult;
  bool succeed = false;
  btx_event_payload_field_integer_signed_get_value(btx_handle, "hipResult", &hipResult, &succeed);
  assert(("Member not found 'hipResult'.", succeed));

  auto lookup = hpt_backend_t("host", vpid, vtid);
  auto it = data->dispatch.find(lookup);
  assert(("Exit reached but not previous entry", it != data->dispatch.end()));

  hostname_t hostname = std::get<0>(it->first);
  process_id_t pid = std::get<1>(it->first);
  thread_id_t tid = std::get<2>(it->first);
  timestamp_t start = it->second;
  backend_t backend = 0;

  dur_t dur = timestamp - start;
  err_t err = hipResult != 0;

  thapi_function_name_t event_name(event_class_name);
  std::size_t i = event_name.find(":");
  std::size_t j = event_name.rfind("_exit");
  std::string sanitized_name = event_name.substr(i + 1, ((j - 1) - i));

  btx_push_message_lttng_host(btx_handle, hostname, vpid, vtid, start, backend,
                              sanitized_name.c_str(), dur, err);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_usr_data(btx_handle, &btx_initialize_usr_data);
  btx_register_callbacks_finalize_usr_data(btx_handle, &btx_finalize_usr_data);
  btx_register_matching_callback_hip(btx_handle, &btx_hip_entry_matcher, &btx_hip_entry_callback);
  btx_register_matching_callback_hip(btx_handle, &btx_hip_exit_matcher, &btx_hip_exit_callback);
}
