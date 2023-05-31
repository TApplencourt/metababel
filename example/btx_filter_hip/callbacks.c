#include <metababel/metababel.h>
#include <stdbool.h>
#include <string.h>
#include <stdio.h>

struct data_s {
  uint64_t entry_count;
  uint64_t exit_count;
  uint64_t hipResult;
};

typedef struct data_s data_t;

void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
  *usr_data = calloc(1, sizeof(data_t));
}

void btx_finalize_usr_data(void *btx_handle, void *usr_data) {
  data_t *data = (data_t *)usr_data;

  printf("entry_count: %d\n", data->entry_count);
  printf("exit_count: %d\n", data->exit_count);
  printf("hipResult: %d\n", data->hipResult);

  free(data);
}

static void btx_hip_entry_matcher(void *btx_handle, void *usr_data, const char* event_class_name, 
                                  bool *matched, uint64_t timestamp, int64_t vpid, uint64_t vtid)
{
  data_t *data = (data_t *)usr_data;
  *matched = strstr(event_class_name, "_entry") != NULL;
}

static void btx_hip_entry_callback(void *btx_handle, void *usr_data, const char* event_class_name, 
                                   uint64_t timestamp, int64_t vpid, uint64_t vtid) 
{
  data_t *data = (data_t *)usr_data;
  data->entry_count += 1;
}

static void btx_hip_exit_matcher(void *btx_handle, void *usr_data, const char* event_class_name, bool *matched, 
                                 uint64_t timestamp, int64_t vpid, uint64_t vtid)
{
  data_t *data = (data_t *)usr_data;
  *matched = strstr(event_class_name, "_exit") != NULL;
}

static void btx_hip_exit_callback(void *btx_handle, void *usr_data, const char* event_class_name, 
                                  uint64_t timestamp, int64_t vpid, uint64_t vtid) 
{
  data_t *data = (data_t *)usr_data;
  data->exit_count += 1;

  int64_t hipResult;
  bool succeed = false;
  btx_event_payload_field_integer_signed_get_value(btx_handle,"hipResult",&hipResult,&succeed);
  data->hipResult = hipResult;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_usr_data(btx_handle, &btx_initialize_usr_data);
  btx_register_callbacks_finalize_usr_data(btx_handle, &btx_finalize_usr_data);
  btx_register_matching_callback_hip(btx_handle, &btx_hip_entry_matcher, &btx_hip_entry_callback);
  btx_register_matching_callback_hip(btx_handle, &btx_hip_exit_matcher, &btx_hip_exit_callback);
}
