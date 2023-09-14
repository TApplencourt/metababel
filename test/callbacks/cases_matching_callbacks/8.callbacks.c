#include <metababel/metababel.h>
#include <assert.h>

static void usr_event_callback(void *btx_handle, void *usr_data, const char *event_class_name) {
  assert(strcmp(event_class_name,"event") == 0);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_usr_event(btx_handle, &usr_event_callback);
}
