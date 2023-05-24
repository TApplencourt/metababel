#include <metababel/metababel.h>
#include <stdbool.h>
#include <assert.h>

struct data_s {
  uint64_t condition_calls_count;
  uint64_t callback_calls_count;
  uint64_t event_1_calls_count;
  uint64_t event_2_calls_count;
};

typedef struct data_s data_t;

void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
  *usr_data = calloc(1, sizeof(data_t));
}

void btx_finalize_usr_data(void *btx_handle, void *usr_data) {
  data_t *data = (data_t *)usr_data;

  assert(data->condition_calls_count == 4);
  assert(data->callback_calls_count == 4);
  
  assert(data->event_1_calls_count == 4);

  free(data);
}

static void btx_condition(void *btx_handle, void *usr_data, const char *event_class_name, bool *matched)
{
  data_t *data = (data_t *)usr_data;
  data->condition_calls_count += 1;
  *matched = true;
}

static void btx_callback(void *btx_handle, void *usr_data, const char *event_class_name)
{
  data_t *data = (data_t *)usr_data;
  data->callback_calls_count += 1;
}

static void event_1_0(void *btx_handle, void *usr_data, uint64_t pf_1) {
  data_t *data = (data_t *)usr_data;
  data->event_1_calls_count += 1;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_usr_data(btx_handle, &btx_initialize_usr_data);
  btx_register_callbacks_finalize_usr_data(btx_handle, &btx_finalize_usr_data);

  btx_register_matching_callback_scA(btx_handle, &btx_condition, &btx_callback);

  btx_register_callbacks_event_1(btx_handle, &event_1_0);
}
