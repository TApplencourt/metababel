require 'base_test'

class TestSourceFilterHostnameEnvNoTimestamp < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/state_machine/cases_hostname_env/1.btx_model.yaml',
        btx_log_path: './test/state_machine/cases_hostname_env/1.btx_log.txt',
      },
    ]

    @btx_output_validation = './test/state_machine/cases_hostname_env/1.btx_log.txt'
  end
end

class TestSourceFilterHostnameEnvWithTimestamp < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/state_machine/cases_hostname_env/2.btx_model.yaml',
        btx_log_path: './test/state_machine/cases_hostname_env/2.btx_log.txt',
      },
    ]

    @btx_output_validation = './test/state_machine/cases_hostname_env/2.btx_log.txt'
  end
end

class TestSupportedEnvironmentInDownstreamModel < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/state_machine/cases_hostname_env/3.btx_model.yaml',
        btx_file_usr_callbacks: './test/state_machine/cases_hostname_env/3.source_callbacks.c',

      },
      {
        btx_component_type: 'SINK',
        btx_component_plugin_name: 'text',
        btx_component_name: 'details',
        btx_compile: false,
      },
    ]

    @btx_output_validation = './test/state_machine/cases_hostname_env/3.btx_log.out'
  end
end
