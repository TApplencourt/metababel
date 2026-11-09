require 'base_test'

# A sink with a model: the events of its model go to their callbacks, the
# other events and messages to on_upstream.
class TestOnUpstreamMessageSink < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/callbacks/cases_on_upstream_message_callback/1.btx_model.yaml',
        btx_log_path: './test/callbacks/cases_on_upstream_message_callback/1.btx_log.txt',
      },
      {
        btx_component_type: 'SINK',
        btx_component_upstream_model: './test/callbacks/cases_on_upstream_message_callback/2.btx_model.yaml',
        btx_file_usr_callbacks: './test/callbacks/cases_on_upstream_message_callback/1.callbacks.c',
        btx_component_enable_callbacks: 'on_upstream',
      },
    ]
    @btx_output_validation = './test/callbacks/cases_on_upstream_message_callback/1.btx_log_out.txt'
  end
end

# A sink without model: every message goes to on_upstream.
class TestOnUpstreamMessageSinkWithoutModel < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/callbacks/cases_on_upstream_message_callback/1.btx_model.yaml',
        btx_log_path: './test/callbacks/cases_on_upstream_message_callback/1.btx_log.txt',
      },
      {
        btx_component_type: 'SINK',
        btx_file_usr_callbacks: './test/callbacks/cases_on_upstream_message_callback/2.callbacks.c',
        btx_component_enable_callbacks: 'on_upstream',
      },
    ]
    @btx_output_validation = './test/callbacks/cases_on_upstream_message_callback/2.btx_log_out.txt'
  end
end
