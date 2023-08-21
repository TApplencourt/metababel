#include <metababel/metababel.h>
#include <assert.h>

static void usr_event_callback(void *btx_handle, void *usr_data, const char *entry_1, int64_t entry_2) {
  assert(strcmp(entry_1,"dummy value") == 0);
  assert(entry_2 == -1);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event(btx_handle, &usr_event_callback);
}
