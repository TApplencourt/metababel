#include <inttypes.h>
#include <metababel/metababel.h>

struct usr_data_s {
  uint64_t i;
  int count;
};

typedef struct usr_data_s usr_data_t;

void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
  usr_data_t *data = (usr_data_t *)calloc(1, sizeof(usr_data_t));
  data->count = 4;
  *usr_data = data;
}

void btx_push_usr_messages(void *btx_handle, void *usr_data,
                           btx_source_status_t *status) {
  usr_data_t *data = (usr_data_t *)usr_data;
  btx_push_message_event_1(btx_handle, data->i++);
  *status = (data->i < data->count) ? BTX_SOURCE_OK : BTX_SOURCE_END;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_usr_data(btx_handle,
                                             &btx_initialize_usr_data);
  btx_register_callbacks_push_usr_messages(btx_handle, &btx_push_usr_messages);
}
