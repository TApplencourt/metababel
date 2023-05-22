#include <metababel/metababel.h>
#include <stdbool.h>
#include <assert.h>

struct data_s {
  uint64_t condition_calls_count;
  uint64_t callback_calls_count;
};

typedef struct data_s data_t;

void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
  data_t *data = calloc(1, sizeof(data_t));
  *usr_data = data;

  data->condition_calls_count = 0;
  data->callback_calls_count = 0;
}

void btx_finalize_usr_data(void *btx_handle, void *usr_data) {
  data_t *data = (data_t *)usr_data;

  assert(data->condition_calls_count == 8);
  assert(data->callback_calls_count == 8);

  free(data);
}

static void btx_condition(void *btx_handle, void *usr_data, bool *matched, const char* event_class_name)
{
  data_t *data = (data_t *)usr_data;
  data->condition_calls_count += 1;
  *matched = true;
}

static void btx_callback(void *btx_handle, void *usr_data, const char* event_class_name)
{
  data_t *data = (data_t *)usr_data;
  data->callback_calls_count += 1;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_usr_data(btx_handle, &btx_initialize_usr_data);
  btx_register_callbacks_finalize_usr_data(btx_handle, &btx_finalize_usr_data);

  // We can use the same condition and callback function because scA and scB do not have common fields
  // Then the function signature is the same in both cases.
  btx_register_matching_callback_scA(btx_handle, &btx_condition, &btx_callback);
  btx_register_matching_callback_scB(btx_handle, &btx_condition, &btx_callback);
}