#include "component.h"
#include "create.h"
#include <stdint.h>

void btx_initialize_usr_data(void *btx_handle, void **usr_data) {}

btx_source_status_t btx_push_usr_messages(void *btx_handle, void *usr_data) {
  btx_push_message_test0(btx_handle, -10, INT32_MAX + 1U, UINT32_MAX);
  btx_push_message_test1_with_colon(btx_handle, -11, 0, UINT32_MAX + 1U, "const char *");
  return BTX_SOURCE_END;
}
