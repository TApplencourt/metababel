#include <assert.h>
#include <metababel/metababel.h>
#include <stdbool.h>
#include <stdio.h>

struct data_s {
  uint64_t mcb_count;
  uint64_t ecb_count;
};

typedef struct data_s data_t;

void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
  *usr_data = calloc(1, sizeof(data_t));
}

void btx_finalize_usr_data(void *btx_handle, void *usr_data) {
  data_t *data = (data_t *)usr_data;
  assert(data->ecb_count == 4);
  assert(data->mcb_count == 4);
  free(data);
}

static void btx_event_callback(void *btx_handle, void *usr_data, const char *cf_1, uint64_t pf_1) {
  data_t *data = (data_t *)usr_data;
  data->ecb_count += 1;
}

static void btx_matching_callback(void *btx_handle, void *usr_data, const char *cf_1, uint64_t pf_1) {
  data_t *data = (data_t *)usr_data;
  data->mcb_count += 1;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_usr_data(btx_handle, &btx_initialize_usr_data);
  btx_register_callbacks_finalize_usr_data(btx_handle, &btx_finalize_usr_data);
  btx_register_callbacks_event_1(btx_handle, &btx_event_callback);
  btx_register_matching_callbacks_usr(btx_handle, &btx_matching_callback);
}
