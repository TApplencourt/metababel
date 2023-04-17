#include <metababel/metababel.h>
#include <assert.h>
#include <stdio.h>

struct data_s {
  uint64_t event_1_calls_count;
  uint64_t event_2_calls_count;
};

typedef struct data_s data_t;

void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
  data_t *data = malloc(sizeof(data_t *));
  *usr_data = data;

  data->event_1_calls_count = 0;
  data->event_2_calls_count = 0;
}

void btx_finalize_usr_data(void *btx_handle, void *usr_data) {
  data_t *data = (data_t *)usr_data;

  assert(data->event_1_calls_count == 4);
  assert(data->event_2_calls_count == 4);

  free(data);
}

static void event_1_0(void *btx_handle, void *usr_data, uint64_t pf_1) {
  data_t *data = (data_t *)usr_data;
  data->event_1_calls_count += 1;
}

static void event_2_0(void *btx_handle, void *usr_data, uint64_t pf_1) {
  data_t *data = (data_t *)usr_data;
  data->event_2_calls_count += 1;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event_1(btx_handle, &event_1_0);
  btx_register_callbacks_event_2(btx_handle, &event_2_0);
}