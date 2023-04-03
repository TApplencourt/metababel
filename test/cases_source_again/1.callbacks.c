#include "component.h"
#include "create.h"
#include <inttypes.h>

struct usr_data_s {
    uint64_t i;
    int count;
};

typedef struct usr_data_s usr_data_t;

void btx_initialize_usr_data(common_data_t *common_data, void **usr_data) {
    usr_data_t *data = (usr_data_t *)  malloc(sizeof(usr_data_t));
    *usr_data = data;
    data->i = 0;
    data->count = 4;
}

btx_source_status_t btx_push_usr_messages(common_data_t *common_data, void *usr_data) {
    usr_data_t *data = (usr_data_t *) usr_data;
    btx_push_message_event_2(common_data, data->i);
    data->i++;
    if (data->i < data->count)
        return BTX_SOURCE_OK;
    return BTX_SOURCE_END;
}
