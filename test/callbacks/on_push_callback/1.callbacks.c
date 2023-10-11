#include <metababel/metababel.h>
#include <babeltrace2/babeltrace.h>
#include <stdio.h>

struct s {
  int counter;
};

void btx_initialize_usr_data(void *btx_handle, void **usr_data) {
  *usr_data = calloc(1, sizeof(struct s));
}

void btx_finalize_usr_data(void *btx_handle, void *usr_data) { free(usr_data); }

static void event_callback(void *btx_handle, void *usr_data, int64_t timestamp) {
  btx_push_message_event(btx_handle, timestamp);
}

static void on_push_callback(void *btx_handle, void *usr_data, const bt_message* message) {
    // Just forward the first message
    if (bt_message_get_type(message) == BT_MESSAGE_TYPE_EVENT)
        ((struct s *)(usr_data))->counter++;
    if (((struct s *)(usr_data))->counter == 1)
        btx_push_message(btx_handle, message);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_usr_data(btx_handle, &btx_initialize_usr_data);
  btx_register_callbacks_finalize_usr_data(btx_handle, &btx_finalize_usr_data);
  btx_register_callbacks_event(btx_handle, &event_callback);
  btx_register_on_push_callback(btx_handle, &on_push_callback);
}
