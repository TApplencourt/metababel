#include <metababel/metababel.h>
#include <stdio.h>

static void usr_foo_event_callback(void *btx_handle, void *usr_data) {
  printf("foo\n");
}

static void usr_bar_event_callback(void *btx_handle, void *usr_data) {
  printf("bar\n");
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_foo(btx_handle, &usr_foo_event_callback);
  btx_register_callbacks_bar(btx_handle, &usr_bar_event_callback);
}
