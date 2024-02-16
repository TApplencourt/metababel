#include <assert.h>
#include <metababel/metababel.h>

struct data_s {
  uint64_t event_1_count;
  uint64_t event_2_count;
};
typedef struct data_s data_t;

void btx_initialize_usr_data(void **usr_data) {
  *usr_data = calloc(1, sizeof(data_t));
}

void btx_finalize_usr_data(void *usr_data) {
  data_t *data = (data_t *)usr_data;

  assert(data->event_1_count == 5);
  assert(data->event_2_count == 10);

  free(data);
}

static void event_1_callback(void *btx_handle, void *usr_data) {
  ((data_t *)usr_data)->event_1_count += 1;
}

static void event_2_callback(void *btx_handle, void *usr_data) {
  ((data_t *)usr_data)->event_2_count += 1;
}

void btx_register_usr_callbacks(void *btx_handle) {
  // TODO: check hostname env
  btx_register_callbacks_initialize_component(btx_handle,
                                              &btx_initialize_usr_data);
  btx_register_callbacks_finalize_component(btx_handle, &btx_finalize_usr_data);
  btx_register_callbacks_event_1(btx_handle, &event_1_callback);
  btx_register_callbacks_event_2(btx_handle, &event_2_callback);
}
