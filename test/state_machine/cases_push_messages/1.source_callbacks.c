#include <metababel/metababel.h>

struct data_s {
  uint64_t i;
  int count;
};

typedef struct data_s data_t;

void btx_initialize_usr_data(void **usr_data) {
  *usr_data = (data_t *)calloc(1, sizeof(data_t));
  ((data_t *)(*usr_data))->count = 4;
}

void btx_finalize_usr_data(void *usr_data) { free(usr_data); }

void btx_push_usr_messages(void *btx_handle, void *usr_data,
                           btx_source_status_t *status) {
  data_t *data = (data_t *)usr_data;
  btx_push_message_event(btx_handle, data->i++);
  *status = (data->i < data->count) ? BTX_SOURCE_OK : BTX_SOURCE_END;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_component(btx_handle,
                                              &btx_initialize_usr_data);
  btx_register_callbacks_finalize_component(btx_handle, &btx_finalize_usr_data);
  btx_register_callbacks_push_usr_messages(btx_handle, &btx_push_usr_messages);
}
