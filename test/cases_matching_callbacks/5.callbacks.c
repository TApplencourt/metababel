#include <assert.h>
#include <metababel/metababel.h>
#include <stdbool.h>
#include <stdio.h>

struct data_s {
  uint64_t user_event_count;
  uint64_t btx_event_count;
};

typedef struct data_s data_t;

void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
  *usr_data = calloc(1, sizeof(data_t));
}

void btx_finalize_usr_data(void *btx_handle, void *usr_data) {
  data_t *data = (data_t *)usr_data;
  assert(data->user_event_count == 4);
  assert(data->btx_event_count == 3);
  free(data);
}

static void usr_event_1_callback(void *btx_handle, void *usr_data, const char *cf_1, uint64_t pf_1) {
  data_t *data = (data_t *)usr_data;
  data->user_event_count += 1;
}

static void btx_event_2_callback(void *btx_handle, void *usr_data, const char *cf_1, uint64_t pf_1) {
  data_t *data = (data_t *)usr_data;
  data->btx_event_count += 1;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_usr_data(btx_handle, &btx_initialize_usr_data);
  btx_register_callbacks_finalize_usr_data(btx_handle, &btx_finalize_usr_data);
  btx_register_callbacks_foo(btx_handle, &usr_event_1_callback);
  btx_register_callbacks_event_2(btx_handle, &btx_event_2_callback);
}