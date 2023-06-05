#include <assert.h>
#include <metababel/metababel.h>
#include <stdbool.h>

struct data_s {
  uint64_t condition_calls_count;
  uint64_t callback_calls_count;
};

typedef struct data_s data_t;

void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
  *usr_data = calloc(1, sizeof(data_t));
}

void btx_finalize_usr_data(void *btx_handle, void *usr_data) {
  data_t *data = (data_t *)usr_data;
  /* Validation is called twice, one per incoming event */
  assert(data->condition_calls_count == 2);
  /* Just one event will match */
  assert(data->callback_calls_count == 1);
  free(data);
}

static void btx_condition(void *btx_handle, void *usr_data, const char *stream_class_name,
                          const char *event_class_name, bool *matched, int64_t timestamp) {
  data_t *data = (data_t *)usr_data;
  data->condition_calls_count += 1;
  *matched = timestamp == 1686003037154215000;
}

static void btx_callback(void *btx_handle, void *usr_data, const char *stream_class_name,
                         const char *event_class_name, int64_t timestamp) {
  data_t *data = (data_t *)usr_data;
  data->callback_calls_count += 1;
  assert(timestamp == 1686003037154215000);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_usr_data(btx_handle, &btx_initialize_usr_data);
  btx_register_callbacks_finalize_usr_data(btx_handle, &btx_finalize_usr_data);
  btx_register_matching_callback_sc1(btx_handle, &btx_condition, &btx_callback);
}
