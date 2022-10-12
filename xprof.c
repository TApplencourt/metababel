#include <babeltrace2/babeltrace.h>
#include <stdio.h>
#include <stdlib.h>
#include "uthash.h"

#include "dispacher_t.h"
#include "xprof_dispatch.h"

#include "my_callbacks.h"

struct xprof_usr_data {};

struct xprof_common_data {
    /* Upstream message iterator (owned by this) */
    bt_message_iterator *message_iterator;
    name_to_dispatcher_t *name_to_dispatcher;
    struct xprof_usr_data *usr_data;
};

static
void lockup_dispatcher(struct xprof_common_data* common_data, 
                       const bt_event_class* event_class, name_to_dispatcher_t** s) {
  const char * class_name = bt_event_class_get_name(event_class);
  HASH_FIND_STR(common_data->name_to_dispatcher, class_name, *s);
}

/*
 * Consume Message
 */

/* TODO: This function should call the callbacks */
bt_component_class_sink_consume_method_status xprof_consume(bt_self_component_sink *self_component_sink) {
  bt_component_class_sink_consume_method_status status =
      BT_COMPONENT_CLASS_SINK_CONSUME_METHOD_STATUS_OK;

  /* Retrieve our private data from the component's user data */
  /* This containt user data and the message iterator */
  struct xprof_common_data *common_data = bt_self_component_get_data(
      bt_self_component_sink_as_self_component(self_component_sink));

  /* Consume a batch of messages from the upstream message iterator */
  bt_message_array_const messages;
  uint64_t message_count;
  bt_message_iterator_next_status next_status = bt_message_iterator_next(
      common_data->message_iterator, &messages, &message_count);

  switch (next_status) {
  case BT_MESSAGE_ITERATOR_NEXT_STATUS_END:
    /* End of iteration: put the message iterator's reference */
    bt_message_iterator_put_ref(common_data->message_iterator);
    status = BT_COMPONENT_CLASS_SINK_CONSUME_METHOD_STATUS_END;
    goto end;
  case BT_MESSAGE_ITERATOR_NEXT_STATUS_AGAIN:
    status = BT_COMPONENT_CLASS_SINK_CONSUME_METHOD_STATUS_AGAIN;
    goto end;
  case BT_MESSAGE_ITERATOR_NEXT_STATUS_MEMORY_ERROR:
    status = BT_COMPONENT_CLASS_SINK_CONSUME_METHOD_STATUS_MEMORY_ERROR;
    goto end;
  case BT_MESSAGE_ITERATOR_NEXT_STATUS_ERROR:
    status = BT_COMPONENT_CLASS_SINK_CONSUME_METHOD_STATUS_ERROR;
    goto end;
  default:
    break;
  }
  /* For each consumed message */
  for (uint64_t i = 0; i < message_count; i++) {
    const bt_message *message = messages[i];
    if (bt_message_get_type(message) != BT_MESSAGE_TYPE_EVENT) {
        goto end;
    }
 
    /* Borrow the event message's event and its class */
    const bt_event *event =
        bt_message_event_borrow_event_const(message);
    const bt_event_class *event_class = bt_event_borrow_class_const(event);

    //printf("%s\n",bt_event_class_get_name(event_class));
    name_to_dispatcher_t* s = NULL;
    lockup_dispatcher(common_data, event_class, &s);
    if (s)
      (*(s->dispatcher))(s->callbacks, event);

    bt_message_put_ref(message);
  }
end:
  return status;
}

/*
 * Initializes the sink component.
 */

// TODO: This should initialize the callbacks
bt_component_class_initialize_method_status xprof_initialize(bt_self_component_sink *self_component_sink,
                          bt_self_component_sink_configuration *configuration,
                          const bt_value *params,
                          void *initialize_method_data) {
  /* Allocate a private data structure */
  struct xprof_common_data *common_data = calloc(1, sizeof(struct xprof_common_data));
  
  /* Register User Callbacks */
  usr_register_callbacks(&common_data->name_to_dispatcher);

  //btx_register_callbacks_lttng_ust_ze_profiling_event_profiling_results(&common_data->name_to_dispatcher, 10);
  //btx_register_callbacks_lttng_ust_ze_profiling_event_profiling_results(&common_data->name_to_dispatcher, 20);
  /* Set the component's user data to our private data structure */
  bt_self_component_set_data(
      bt_self_component_sink_as_self_component(self_component_sink),
        common_data);

  /*
   * Add an input port named `in` to the sink component.
   *
   * This is needed so that this sink component can be connected to a
   * filter or a source component. With a connected upstream
   * component, this sink component can create a message iterator
   * to consume messages.
   */
  bt_self_component_sink_add_input_port(self_component_sink, "in", NULL, NULL);
  return BT_COMPONENT_CLASS_INITIALIZE_METHOD_STATUS_OK;
}

void xprof_finalize(bt_self_component_sink *self_component_sink) {
  struct xprof_common_data *common_data = bt_self_component_get_data(
      bt_self_component_sink_as_self_component(self_component_sink));
  /* Free the allocated structure */
  free(common_data->usr_data);
  free(common_data);
}

/*
 * Called when the trace processing graph containing the sink component
 * is configured.
 *
 * This is where we can create our upstream message iterator.
 */
bt_component_class_sink_graph_is_configured_method_status
xprof_graph_is_configured(bt_self_component_sink *self_component_sink) {
  /* Retrieve our private data from the component's user data */
  struct xprof_common_data *common_data = bt_self_component_get_data(
      bt_self_component_sink_as_self_component(self_component_sink));

  /* Borrow our unique port */
  bt_self_component_port_input *in_port =
      bt_self_component_sink_borrow_input_port_by_index(self_component_sink, 0);

  /* Create the uptream message iterator */
  bt_message_iterator_create_from_sink_component(self_component_sink, in_port,
                                                 &common_data->message_iterator);

  return BT_COMPONENT_CLASS_SINK_GRAPH_IS_CONFIGURED_METHOD_STATUS_OK;
}


/* Mandatory */
BT_PLUGIN_MODULE();

BT_PLUGIN(sink);
// Maybe we should createonly one pluging
/* Add the output  component class */
BT_PLUGIN_SINK_COMPONENT_CLASS(xprof, xprof_consume);

BT_PLUGIN_SINK_COMPONENT_CLASS_INITIALIZE_METHOD(xprof,
                                                 xprof_initialize);
BT_PLUGIN_SINK_COMPONENT_CLASS_FINALIZE_METHOD(xprof,
                                               xprof_finalize);

BT_PLUGIN_SINK_COMPONENT_CLASS_GRAPH_IS_CONFIGURED_METHOD(
    xprof, xprof_graph_is_configured);
