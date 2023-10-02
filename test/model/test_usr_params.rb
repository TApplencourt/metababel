require 'base_test'

class TestUserParams < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/model/cases_usr_params/1.btx_model.yaml',
        btx_component_params_model: './test/model/cases_usr_params/1.btx_params.yaml',
        btx_component_params: 'param_1=\"\",param_2=false,param_3=1',
        btx_file_usr_callbacks: './test/model/cases_usr_params/1.callbacks.c',
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/model/cases_usr_params/1.btx_model.yaml',
        btx_component_downstream_model: './test/model/cases_usr_params/1.btx_model.yaml',
        btx_component_params_model: './test/model/cases_usr_params/1.btx_params.yaml',
        btx_component_params: 'param_1=\"\",param_2=false,param_3=1',
        btx_file_usr_callbacks: './test/model/cases_usr_params/1.callbacks.c',
      },
      {
        btx_component_type: 'SINK',
        btx_component_upstream_model: './test/model/cases_usr_params/1.btx_model.yaml',
        btx_component_params_model: './test/model/cases_usr_params/1.btx_params.yaml',
        btx_component_params: 'param_1=\"\",param_2=false,param_3=1',
        btx_file_usr_callbacks: './test/model/cases_usr_params/1.callbacks.c',
      },
    ]
  end
end
