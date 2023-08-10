require 'base_test'

class TestCallAutomaticCallbackWithTimestamp < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/callbacks/cases_automatic_callbacks/1.btx_model.yaml',
        btx_log_path: './test/callbacks/cases_automatic_callbacks/1.btx_log.txt'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/callbacks/cases_automatic_callbacks/1.btx_model.yaml',
        btx_component_downstream_model: './test/callbacks/cases_automatic_callbacks/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/callbacks/cases_automatic_callbacks/1.callbacks.c'
      }
    ]

    @btx_output_validation = './test/callbacks/cases_automatic_callbacks/1.btx_log.txt'
  end
end
