require 'base_test'

class TestSourceParamsEmpty < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_params: './test/cases_source_params/1.btx_params_model.yaml',
        btx_component_downstream_model: './test/cases_source_params/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/cases_source_params/1.callback.c',
        btx_log_path: './test/cases_source_params/1.btx_log.txt',
      }
    ]
  end
end
