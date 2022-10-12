#pragma once
#include "uthash.h"
#include "utarray.h"
#include <babeltrace2/babeltrace.h>

typedef void (dispatcher_t)
    ( UT_array *callbacks,
      const bt_event *message);

struct name_to_dispatcher_s {
    const char *name;
    dispatcher_t *dispatcher;
    UT_array *callbacks;    
    UT_hash_handle hh;
};
typedef struct name_to_dispatcher_s name_to_dispatcher_t;
