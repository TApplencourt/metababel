#include <metababel/metababel.h>
#include <assert.h>

static void usr_event_callback(void *btx_handle, void *usr_data, int64_t entry_2, const char *entry_1) {
  assert(entry_2 == -1);
  assert(strcmp(entry_1,"dummy value") == 0);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_usr_event(btx_handle, &usr_event_callback);
}
