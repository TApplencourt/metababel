require 'base_test'

class TestSinkMatchingCallbacksCalled < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_filter_state_machine/1.A.btx_model.yaml',
        btx_log_path: './test/cases_filter_state_machine/1.A.btx_log.txt'
      },
      {
        btx_component_label: 'C',
        btx_component_type: 'SINK',
        btx_component_upstream_model: './test/cases_filter_state_machine/1.A.btx_model.yaml',
        btx_file_usr_callbacks: './test/cases_sink_matching_callbacks/1.callbacks.c'
      }
    ]
  end
end

class TestSinkMatchingNoCallbacksCalled < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_filter_state_machine/1.A.btx_model.yaml',
        btx_log_path: './test/cases_filter_state_machine/1.A.btx_log.txt'
      },
      {
        btx_component_label: 'C',
        btx_component_type: 'SINK',
        btx_component_upstream_model: './test/cases_filter_state_machine/1.A.btx_model.yaml',
        btx_file_usr_callbacks: './test/cases_sink_matching_callbacks/2.callbacks.c'
      }
    ]
  end
end

class TestSinkMatchingCallbacksAndRegularDistapacher < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_filter_state_machine/1.A.btx_model.yaml',
        btx_log_path: './test/cases_filter_state_machine/1.A.btx_log.txt'
      },
      {
        btx_component_label: 'C',
        btx_component_type: 'SINK',
        btx_component_upstream_model: './test/cases_filter_state_machine/1.A.btx_model.yaml',
        btx_file_usr_callbacks: './test/cases_sink_matching_callbacks/3.callbacks.c'
      }
    ]
  end
end