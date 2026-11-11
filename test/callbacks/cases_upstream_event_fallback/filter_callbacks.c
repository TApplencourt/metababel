#include <babeltrace2/babeltrace.h>
#include <metababel/metababel.h>
#include <stdlib.h>

static void btx_initialize_usr_data(void **usr_data) { *usr_data = calloc(1, sizeof(int)); }

static void btx_finalize_usr_data(void *usr_data) { free(usr_data); }

/* Dispatched: metababel puts event_a after the callback, it never goes downstream. */
static void event_a_callback(void *btx_handle, void *usr_data, uint64_t value) {}

/* The callback owns the message: forward the first event_b, drop the others. */
static void fallback_callback(void *btx_handle, void *usr_data, const bt_message *message) {
  int *count = (int *)usr_data;
  if ((*count)++ == 0)
    btx_push_message(btx_handle, message);
  else
    bt_message_put_ref(message);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_initialize_component(btx_handle, &btx_initialize_usr_data);
  btx_register_callbacks_finalize_component(btx_handle, &btx_finalize_usr_data);
  btx_register_callbacks_event_a(btx_handle, &event_a_callback);
  btx_register_callbacks_upstream_event_fallback(btx_handle, &fallback_callback);
}
