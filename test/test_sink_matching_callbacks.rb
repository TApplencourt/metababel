require 'base_test'

class TestSinkMatchingAndRegularEventCallbacksDispatchDifferentEvents < Test::Unit::TestCase
  # Regular callbacks dispatch event_1 while matching callbacks dispatch event_2.
  # This is the same test performed for Filter, we used it here to test the 
  # sink state machine when having automatic and user events

  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_matching_callbacks/5.btx_model.yaml',
        btx_log_path: './test/cases_matching_callbacks/5.btx_log.txt'
      },
      {
        btx_component_type: 'SINK',
        btx_component_upstream_model: './test/cases_matching_callbacks/5.btx_model.yaml',
        btx_component_downstream_model: './test/cases_matching_callbacks/5.btx_model.yaml',
        btx_component_callbacks: './test/cases_matching_callbacks/5.btx_callbacks.yaml',
        btx_file_usr_callbacks: './test/cases_matching_callbacks/5.callbacks.c'
      }
    ]
  end
end
