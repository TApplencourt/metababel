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
        btx_log_path: './test/callbacks/cases_automatic_callbacks/1.btx_log.txt',
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/callbacks/cases_automatic_callbacks/1.btx_model.yaml',
        btx_component_downstream_model: './test/callbacks/cases_automatic_callbacks/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/callbacks/cases_automatic_callbacks/1.callbacks.c',
        btx_component_enable_callbacks: 'on_downstream',
      },
    ]

    @btx_output_validation = './test/callbacks/cases_automatic_callbacks/1.btx_log.txt'
  end
end

class TestCallTwoCallbacksForOneEvent < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/callbacks/cases_automatic_callbacks/2.btx_model.yaml',
        btx_log_path: './test/callbacks/cases_automatic_callbacks/2.btx_log.in',
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/callbacks/cases_automatic_callbacks/2.btx_model.yaml',
        btx_component_downstream_model: './test/callbacks/cases_automatic_callbacks/2.btx_model.yaml',
        btx_file_usr_callbacks: './test/callbacks/cases_automatic_callbacks/2.callbacks.c',
        btx_component_enable_callbacks: 'on_downstream',
      },
    ]

    @btx_output_validation = './test/callbacks/cases_automatic_callbacks/2.btx_log.out'
  end
end

class TestCallAutomaticCallbackWithEnvironmentVariables < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/callbacks/cases_automatic_callbacks/3.btx_downstream_model.yaml',
        btx_file_usr_callbacks: './test/callbacks/cases_automatic_callbacks/3.source_callbacks.c',
      },
      {
        btx_component_type: 'SINK',
        btx_component_upstream_model: './test/callbacks/cases_automatic_callbacks/3.btx_upstream_model.yaml',
        btx_file_usr_callbacks: './test/callbacks/cases_automatic_callbacks/3.sink_callbacks.c',
      },
    ]
  end
end
