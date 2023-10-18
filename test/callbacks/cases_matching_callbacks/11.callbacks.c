#include <metababel/metababel.h>
#include <assert.h>

static void usr_event_callback_1(void *btx_handle, void *usr_data, const char * event_class_name) {
  assert(strcmp(event_class_name,"event_1") == 0);
}

static void usr_event_callback_2(void *btx_handle, void *usr_data, const char * event_class_name, uint64_t pf_1) {
  assert(strcmp(event_class_name,"event_1") == 0);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_usr_event_1(btx_handle, &usr_event_callback_1);
  btx_register_callbacks_usr_event_2(btx_handle, &usr_event_callback_2);
}
