#include <metababel/metababel.h>
#include <assert.h>

static void event_callback(void *btx_handle, void *usr_data, struct point pt) {
  assert(pt.x == 10);
  assert(pt.y == -20);
  assert(pt.z == 30);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_event(btx_handle, &event_callback);
}
