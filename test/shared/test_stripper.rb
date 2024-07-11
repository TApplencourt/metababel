require 'base_test'

class TestStripperNoParams < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/shared/cases_stripper/1.btx_model.yaml',
        btx_log_path: './test/shared/cases_stripper/1.btx_log.in',
      },
      {
        btx_component_type: 'FILTER',
        btx_file_usr_callbacks: './shared/stripper.cpp',
        btx_component_enable_callbacks: 'on_downstream',
        btx_component_params_model: './shared/stripper_params.yaml',
      },
      {
        btx_component_type: 'SINK',
        btx_component_plugin_name: 'text',
        btx_component_name: 'details',
        btx_compile: false,
      }
    ]

    @btx_output_validation = './test/shared/cases_stripper/1.btx_log.out'
  end
end

class TestStripperParams < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/shared/cases_stripper/1.btx_model.yaml',
        btx_log_path: './test/shared/cases_stripper/2.btx_log.in',
      },
      {
        btx_component_type: 'FILTER',
        btx_file_usr_callbacks: './shared/stripper.cpp',
        btx_component_enable_callbacks: 'on_downstream',
        btx_component_params_model: './shared/stripper_params.yaml',
        btx_component_params: 'filter_prefix=event1',
      },
      {
        btx_component_type: 'SINK',
        btx_component_plugin_name: 'text',
        btx_component_name: 'details',
        btx_compile: false,
      }
    ]

    @btx_output_validation = './test/shared/cases_stripper/2.btx_log.out'
  end
end

