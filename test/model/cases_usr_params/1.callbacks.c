#include <metababel/metababel.h>
#include <assert.h>

void btx_read_params(void *usr_data, btx_param_0_t *usr_params) {
  assert(strcmp(usr_params->param_1,"") == 0);
  assert(usr_params->param_2 == BT_FALSE);
  assert(usr_params->param_3 == 1);
  assert(usr_params->param_4.param_4_1 == 12);
}

void btx_register_usr_callbacks(void *btx_handle) {
  btx_register_callbacks_read_params(btx_handle, &btx_read_params);
}
