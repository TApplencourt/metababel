#include <metababel/metababel.h>
#include <assert.h>

struct data_s {
  uint64_t usr_event_count;
  uint64_t btx_event_count;
};

typedef struct data_s data_t;

void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
  *usr_data = calloc(1, sizeof(data_t));
}

void btx_finalize_usr_data(void *btx_handle, void *usr_data) {
  data_t *data = (data_t *)usr_data;
  assert(data->usr_event_count == 2);
  assert(data->btx_event_count == 1);
  free(data);
}

static void usr_event_1_2_callback(void *btx_handle, void *usr_data, const char *event_class_name) {
  ((data_t *)usr_data)->usr_event_count += 1;
}

static void btx_event_3_callback(void *btx_handle, void *usr_data) {
  ((data_t *)usr_data)->btx_event_count += 1;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_usr_data(btx_handle, &btx_initialize_usr_data);
  btx_register_callbacks_finalize_usr_data(btx_handle, &btx_finalize_usr_data);
  btx_register_callbacks_usr_event(btx_handle, &usr_event_1_2_callback);
  btx_register_callbacks_event_3(btx_handle, &btx_event_3_callback);
}
