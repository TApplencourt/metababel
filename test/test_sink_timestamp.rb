require 'base_test'

class TestSinkTimestampRegularDispacther < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_sink_timestamp/1.btx_model.yaml',
        btx_log_path: './test/cases_sink_timestamp/1.btx_log.txt'
      },
      {
        btx_component_type: 'SINK',
        btx_component_upstream_model: './test/cases_sink_timestamp/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/cases_sink_timestamp/1.callbacks.c'
      }
    ]

    @btx_output_validation = './test/cases_sink_timestamp/1.btx_out.txt'
  end
end

class TestSinkTimestampMatchingDispacther < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_sink_timestamp/1.btx_model.yaml',
        btx_log_path: './test/cases_sink_timestamp/1.btx_log.txt'
      },
      {
        btx_component_type: 'SINK',
        btx_component_upstream_model: './test/cases_sink_timestamp/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/cases_sink_timestamp/2.callbacks.c'
      }
    ]

    @btx_output_validation = './test/cases_sink_timestamp/1.btx_out.txt'
  end
end
