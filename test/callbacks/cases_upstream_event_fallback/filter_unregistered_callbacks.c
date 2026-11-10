#include <metababel/metababel.h>

/* Dispatched: metababel puts event_a after the callback, it never goes downstream. */
static void event_a_callback(void *btx_handle, void *usr_data, uint64_t value) {}

/* No fallback callback registered: the events go downstream (passthrough). */
void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event_a(btx_handle, &event_a_callback);
}
