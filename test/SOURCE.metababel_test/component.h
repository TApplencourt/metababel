#pragma once

#include "utarray.h"
#include "uthash.h"
#include <babeltrace2/babeltrace.h>

#ifdef __cplusplus
extern "C" {
#endif

// Forward declaration of common_data
struct common_data_s;
typedef struct common_data_s common_data_t;

// Params
struct params_s {

}; 
typedef struct params_s params_t;

// Dispatcher
// Structure for Downstream Message
struct el {
  const bt_message *message;
  struct el *next, *prev;
};

// Struct stored in the component via `bt_self_component_set_data`
struct common_data_s {
  void *usr_data;
  const bt_value *params;
  bt_trace *downstream_trace;
  /* Used by downstream.c */
  bt_self_message_iterator *self_message_iterator;
};

enum btx_source_state_e {
  BTX_SOURCE_STATE_INITIALIZING,
  BTX_SOURCE_STATE_PROCESSING,
  BTX_SOURCE_STATE_FINALIZING,
  BTX_SOURCE_STATE_FINISHED,
  BTX_SOURCE_STATE_ERROR,
};
typedef enum btx_source_state_e btx_source_state_t;

/* Message iterator's private data */
struct btx_message_iterator_s {
  /* (Weak) link to the component's private data */
  common_data_t *common_data;
  btx_source_state_t state;

  /* Handling the downstream message queue */
  struct el *queue;
  struct el *pool;
};
typedef struct btx_message_iterator_s btx_message_iterator_t;

enum btx_source_status_e {
  BTX_SOURCE_END,
  BTX_SOURCE_OK,
};
typedef enum btx_source_status_e btx_source_status_t;


/* Implemented by params.c */
void btx_read_params(void *btx_handle, params_t *usr_params);

void btx_initialize_usr_data(void *btx_handle, void **usr_data);
btx_source_status_t btx_push_usr_messages(void *btx_handle, void *usr_data);

#ifdef __cplusplus
}
#endif
