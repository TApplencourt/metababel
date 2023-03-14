#include "component.h"
#include "create.h"
#include <stdio.h>
#include <stdint.h>

void btx_initialize_usr_data(common_data_t *common_data, void **usr_data) {
}

btx_source_status_t btx_push_usr_messages(struct common_data_s *common_data) {
    btx_push_message_test0(common_data, -10, INT32_MAX+1U, UINT32_MAX);
    btx_push_message_test1_with_colon(common_data, -11, 0, UINT32_MAX+1U, "const char *");
    return BTX_SOURCE_END;
}
