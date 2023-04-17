#include <inttypes.h>
#include <metababel/metababel.h>

struct usr_data_s {
  uint64_t i;
  int count;
};

typedef struct usr_data_s usr_data_t;

void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
  usr_data_t *data = (usr_data_t *)malloc(sizeof(usr_data_t));
  *usr_data = data;
  data->i = 0;
  data->count = 4;
}

void btx_push_usr_messages(void *btx_handle, void *usr_data,
                           btx_source_status_t *status) {
  usr_data_t *data = (usr_data_t *)usr_data;
  btx_push_message_event_2(btx_handle, data->i);
  data->i++;
  if (data->i < data->count)
    *status = BTX_SOURCE_OK;
  else
    *status = BTX_SOURCE_END;
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_usr_data(btx_handle,
                                             &btx_initialize_usr_data);
  btx_register_callbacks_push_usr_messages(btx_handle, &btx_push_usr_messages);
}
