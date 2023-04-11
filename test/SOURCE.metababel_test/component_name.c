#include "uthash.h"
#include "utlist.h"
#include <babeltrace2/babeltrace.h>
#include <stdio.h>
#include <stdlib.h>

#include "component.h"
#include "downstream.h"

/* Loosely inspired by
 * https://babeltrace.org/docs/v2.0/libbabeltrace2/example-simple-src-cmp-cls.html
 */

/*
 *  Handle Upstream Messages
 */
static bt_message_iterator_class_next_method_status
source_message_iterator_next(bt_self_message_iterator *self_message_iterator,
                             bt_message_array_const messages, uint64_t capacity,
                             uint64_t *count) {

  /* The clean thing to do will be to refractor the code, so we can reuse some
   * part of the filter state-machine... For now unoptimal and simple state
   * machine will be enough */

  /* Retrieve our private data from the message iterator's user data */
  btx_message_iterator_t *message_iterator_private_data =
      bt_self_message_iterator_get_data(self_message_iterator);

  /* When you return BT_MESSAGE_ITERATOR_CLASS_NEXT_METHOD_STATUS_END, you must
   * not put any message into the message array */
  switch (message_iterator_private_data->state) {
  case BTX_SOURCE_STATE_INITIALIZING:
    btx_push_messages_stream_beginning(self_message_iterator,
                                       message_iterator_private_data);
    message_iterator_private_data->state = BTX_SOURCE_STATE_PROCESSING;
    return BT_MESSAGE_ITERATOR_CLASS_NEXT_METHOD_STATUS_AGAIN;
  case BTX_SOURCE_STATE_PROCESSING:
    if (message_iterator_private_data->queue) {
      btx_downstream_move_messages(message_iterator_private_data, messages,
                                   capacity, count);
      return BT_MESSAGE_ITERATOR_CLASS_NEXT_METHOD_STATUS_OK;
    }
    btx_source_status_t status = btx_push_usr_messages(
        message_iterator_private_data->common_data,
        message_iterator_private_data->common_data->usr_data);
    if (status == BTX_SOURCE_END) {
      btx_push_messages_stream_end(self_message_iterator,
                                   message_iterator_private_data);
      message_iterator_private_data->state = BTX_SOURCE_STATE_FINALIZING;
    }
    return BT_MESSAGE_ITERATOR_CLASS_NEXT_METHOD_STATUS_AGAIN;
  case BTX_SOURCE_STATE_FINALIZING:
    if (message_iterator_private_data->queue) {
      btx_downstream_move_messages(message_iterator_private_data, messages,
                                   capacity, count);
      return BT_MESSAGE_ITERATOR_CLASS_NEXT_METHOD_STATUS_OK;
    }
    message_iterator_private_data->state = BTX_SOURCE_STATE_FINISHED;
    return BT_MESSAGE_ITERATOR_CLASS_NEXT_METHOD_STATUS_END;
  case BTX_SOURCE_STATE_FINISHED:
    return BT_MESSAGE_ITERATOR_CLASS_NEXT_METHOD_STATUS_END;
  default:
    return BT_MESSAGE_ITERATOR_CLASS_NEXT_METHOD_STATUS_ERROR;
  }
}

/*
 * Initializes the source component.
 */
bt_component_class_initialize_method_status
source_initialize(bt_self_component_source *self_component_source,
                  bt_self_component_source_configuration *configuration,
                  const bt_value *params, void *initialize_method_data) {
  /* Allocate a private data structure */
  common_data_t *common_data = calloc(1, sizeof(common_data_t));
  common_data->params = params;
  bt_value_get_ref(common_data->params);
  /* Register User Data */
  btx_initialize_usr_data((void *)common_data, &common_data->usr_data);

  /* Upcast `self_component_source` to the `bt_self_component` type */
  bt_self_component *self_component =
      bt_self_component_source_as_self_component(self_component_source);

  bt_trace_class *trace_class =
      btx_downstream_trace_class_create_rec(self_component);

  /* Instantiate a `downstream_trace` of `trace_class` and all the children
   * stream */
  common_data->downstream_trace = btx_downstream_trace_create_rec(trace_class);

  /* Set the component's user data to our private data structure */
  bt_self_component_set_data(self_component, common_data);

  /*
   * Add an output port named `out` to the source component.
   *
   * This is needed so that this source component can be connected to
   * a filter or a sink component. Once a downstream component is
   * connected, it can create our message iterator.
   */
  bt_self_component_source_add_output_port(self_component_source, "out", NULL,
                                           NULL);

  return BT_COMPONENT_CLASS_INITIALIZE_METHOD_STATUS_OK;
}

/*
 * Initializes the message iterator.
 */
static bt_message_iterator_class_initialize_method_status
source_message_iterator_initialize(
    bt_self_message_iterator *self_message_iterator,
    bt_self_message_iterator_configuration *configuration,
    bt_self_component_port_output *self_port) {
  /* Allocate a private data structure */
  btx_message_iterator_t *message_iterator_private_data =
      calloc(1, sizeof(btx_message_iterator_t));

  message_iterator_private_data->state = BTX_SOURCE_STATE_INITIALIZING;

  /* Retrieve the component's private data from its user data */
  common_data_t *common_data = bt_self_component_get_data(
      bt_self_message_iterator_borrow_component(self_message_iterator));

  /* Save a link to the self_message_iterator */
  common_data->self_message_iterator = self_message_iterator;

  /* Keep a link to the component's private data */
  message_iterator_private_data->common_data = common_data;

  /* Set the message iterator's user data to our private data structure */
  bt_self_message_iterator_set_data(self_message_iterator,
                                    message_iterator_private_data);

  return BT_MESSAGE_ITERATOR_CLASS_INITIALIZE_METHOD_STATUS_OK;
}

static void source_finalize(bt_self_component_source *self_component_source) {
  common_data_t *common_data = bt_self_component_get_data(
      bt_self_component_source_as_self_component(self_component_source));

  // TODO: Missing {initizialize,finialize}_usr_source
  bt_value_put_ref(common_data->params);
  free(common_data);
}

static void source_message_iterator_finalize(
    bt_self_message_iterator *self_message_iterator) {
  /* Retrieve our private data from the message iterator's user data */
  btx_message_iterator_t *message_iterator_private_data =
      bt_self_message_iterator_get_data(self_message_iterator);

  struct el *elt, *tmp;
  DL_FOREACH_SAFE(message_iterator_private_data->pool, elt, tmp) {
    DL_DELETE(message_iterator_private_data->pool, elt);
    free(elt);
  }

  /* Free the allocated structure */
  free(message_iterator_private_data);
}

/* Mandatory */
BT_PLUGIN_MODULE();

BT_PLUGIN(pluggin_name);
BT_PLUGIN_SOURCE_COMPONENT_CLASS(component_name,
                                 source_message_iterator_next);

BT_PLUGIN_SOURCE_COMPONENT_CLASS_INITIALIZE_METHOD(component_name,
                                                   source_initialize);
BT_PLUGIN_SOURCE_COMPONENT_CLASS_FINALIZE_METHOD(component_name,
                                                 source_finalize);
BT_PLUGIN_SOURCE_COMPONENT_CLASS_MESSAGE_ITERATOR_CLASS_INITIALIZE_METHOD(
    component_name, source_message_iterator_initialize);
BT_PLUGIN_SOURCE_COMPONENT_CLASS_MESSAGE_ITERATOR_CLASS_FINALIZE_METHOD(
    component_name, source_message_iterator_finalize);
