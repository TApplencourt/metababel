require 'base_test'

class TestDownstreamMessageFilter < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/callbacks/cases_downstream_message_callback/1.btx_model.yaml',
        btx_log_path: './test/callbacks/cases_downstream_message_callback/1.btx_log.txt',
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/callbacks/cases_downstream_message_callback/1.btx_model.yaml',
        btx_component_downstream_model: './test/callbacks/cases_downstream_message_callback/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/callbacks/cases_downstream_message_callback/1.callbacks.c',
        btx_component_downstream_message: 'callback',
      },
    ]
    @btx_output_validation = './test/callbacks/cases_downstream_message_callback/1.btx_log_out.txt'
    @btx_ctf_roundtrip_bug = CTF_ROUNDTRIP_BUG_CLOCK
  end
end

class TestDownstreamMessageCount < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/callbacks/cases_downstream_message_callback/1.btx_model.yaml',
        btx_log_path: './test/callbacks/cases_downstream_message_callback/1.btx_log.txt',
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/callbacks/cases_downstream_message_callback/1.btx_model.yaml',
        btx_component_downstream_model: './test/callbacks/cases_downstream_message_callback/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/callbacks/cases_downstream_message_callback/2.callbacks.c',
        btx_component_downstream_message: 'callback',
      },
    ]
    @btx_ctf_roundtrip_bug = CTF_ROUNDTRIP_BUG_CLOCK
  end
end

class TestDownstreamMessageSource < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/callbacks/cases_downstream_message_callback/2.btx_model.yaml',
        btx_file_usr_callbacks: './test/callbacks/cases_downstream_message_callback/3.source_callbacks.c',
        btx_component_downstream_message: 'callback',
      },
    ]
    @btx_output_validation = './test/callbacks/cases_downstream_message_callback/3.btx_log_out.txt'
  end
end

# A sink has no downstream.
class TestDownstreamMessageSinkInvalid < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SINK',
        btx_component_upstream_model: './test/callbacks/cases_downstream_message_callback/1.btx_model.yaml',
        btx_component_downstream_message: 'callback',
        btx_metababel_generation_fail: true,
      },
    ]
  end
end
