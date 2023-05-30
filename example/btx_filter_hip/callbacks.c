#include <metababel/metababel.h>
#include <stdbool.h>
#include <string.h>
#include <stdio.h>

struct data_s {
  uint64_t entry_count;
  uint64_t exit_count;
};

typedef struct data_s data_t;

void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
  *usr_data = calloc(1, sizeof(data_t));
}

void btx_finalize_usr_data(void *btx_handle, void *usr_data) {
  data_t *data = (data_t *)usr_data;

  printf("entry_count: %d\n", data->entry_count);
  printf("exit_count: %d\n", data->exit_count);

  free(data);
}

static void btx_entry_matcher(void *btx_handle, void *usr_data, const char* event_class_name, bool *matched, int64_t vpid, uint64_t vtid)
{
  data_t *data = (data_t *)usr_data;
  *matched = strstr(event_class_name, "_entry") != NULL;
}

static void btx_entry_callback(void *btx_handle, void *usr_data, const char* event_class_name, int64_t vpid, uint64_t vtid) {
  data_t *data = (data_t *)usr_data;
  data->entry_count += 1;
}

static void btx_exit_matcher(void *btx_handle, void *usr_data, const char* event_class_name, bool *matched, int64_t vpid, uint64_t vtid)
{
  data_t *data = (data_t *)usr_data;
  *matched = strstr(event_class_name, "_exit") != NULL;
}

static void btx_exit_callback(void *btx_handle, void *usr_data, const char* event_class_name, int64_t vpid, uint64_t vtid) {
  data_t *data = (data_t *)usr_data;
  data->exit_count += 1;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_usr_data(btx_handle, &btx_initialize_usr_data);
  btx_register_callbacks_finalize_usr_data(btx_handle, &btx_finalize_usr_data);
  btx_register_matching_callback_hip(btx_handle, &btx_entry_matcher, &btx_entry_callback);
  btx_register_matching_callback_hip(btx_handle, &btx_exit_matcher, &btx_exit_callback);
}
