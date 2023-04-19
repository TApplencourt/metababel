#include <assert.h>
#include <metababel/metababel.h>

struct data_s {
  uint64_t count;
};

typedef struct data_s data_t;

void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
  *usr_data = calloc(1, sizeof(data_t *));
}

void btx_finalize_usr_data(void *btx_handle, void *usr_data) {
  data_t *data = (data_t *)usr_data;
  assert(data->count == 1);
  free(data);
}

void btx_read_params(void *btx_handle, void *usr_data,
                     btx_params_t *usr_params) {
  ((data_t *)usr_data)->count += 1;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_usr_data(btx_handle,
                                             &btx_initialize_usr_data);
  btx_register_callbacks_finalize_usr_data(btx_handle, &btx_finalize_usr_data);
  btx_register_callbacks_read_params(btx_handle, &btx_read_params);
}
