#include <babeltrace2/babeltrace.h>
#include <metababel/metababel.h>
#include <stdlib.h>

static void btx_initialize_usr_data(void **usr_data) { *usr_data = calloc(1, sizeof(int)); }

static void btx_finalize_usr_data(void *usr_data) { free(usr_data); }

/* Dispatched: metababel puts event_a after the callback, it never goes downstream. */
static void event_a_callback(void *btx_handle, void *usr_data, uint64_t value) {}

static void fallback_callback(void *btx_handle, void *usr_data, const bt_message *message) {
  btx_push_message(btx_handle, message);
}

/* What btx_push_message sends comes here too: drop the first event. */
static void downstream_message_callback(void *btx_handle, void *usr_data,
                                        const bt_message *message) {
  if (!(bt_message_get_type(message) == BT_MESSAGE_TYPE_EVENT && ++*(int *)usr_data == 1))
    btx_direct_push_message(btx_handle, message);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_component(btx_handle, &btx_initialize_usr_data);
  btx_register_callbacks_finalize_component(btx_handle, &btx_finalize_usr_data);
  btx_register_callbacks_event_a(btx_handle, &event_a_callback);
  btx_register_callback_upstream_event_fallback(btx_handle, &fallback_callback);
  btx_register_callback_downstream_message(btx_handle, &downstream_message_callback);
}
