#include <metababel/metababel.h>
#include <assert.h>

static void event_set_callback(void *btx_handle, void *usr_data, const char * event_class_name) {}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event_set(btx_handle, &event_set_callback);
}
