require 'base_test'

class TestSinkMatchingCallbacksCalled < Test::Unit::TestCase
  # Validate the proper calling of both regular and matching callbacks.
  # Regular callbacks dispatch event_1 while matching callbacks dispatch
  # event_2.

  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_matching_callbacks/1.btx_model.yaml',
        btx_log_path: './test/cases_matching_callbacks/1.btx_log.txt'
      },
      {
        btx_component_type: 'SINK',
        btx_component_upstream_model: './test/cases_matching_callbacks/1.btx_model.yaml',
        btx_component_downstream_model: './test/cases_matching_callbacks/1.btx_model.yaml',
        btx_component_callbacks: './test/cases_matching_callbacks/1.btx_callbacks.yaml',
        btx_file_usr_callbacks: './test/cases_matching_callbacks/1.callbacks.c'
      }
    ]
  end
end