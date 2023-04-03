require 'base_test'

class TestSourceStateMachineAgain < Test::Unit::TestCase
  include SourceTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_source_state_machine/1.btx_model.yaml',
      btx_log_path: './test/cases_source_state_machine/1.btx_log.txt',
      btx_component_type: 'SOURCE',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_tests',
      btx_callbacks_path: './test/cases_source_state_machine/1.callbacks.c',
      btx_component_path: './test/SOURCE.metababel_test'
    }
  end
end
