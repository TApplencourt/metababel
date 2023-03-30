require 'base_test'

class TestSinkCase1 < Test::Unit::TestCase
  include SinkTest
  extend VariableAccessor
  include VariableClassAccessor
  
  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_sink_messages_count_integrity/1.btx_model.yaml',
      btx_log_path: './test/cases_sink_messages_count_integrity/1.btx_log.txt',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_source',
      btx_component_path: './test/SOURCE.metababel_test'
    }

    @btx_sink_variables = {
      btx_model_path: './test/cases_sink_messages_count_integrity/1.btx_model.yaml',
      btx_log_path: './test/cases_sink_messages_count_integrity/1.btx_log.txt',
      btx_callbacks_path: './test/cases_sink_messages_count_integrity/1.callbacks.c',
      btx_component_name: 'sink',
      btx_pluggin_name: 'metababel_sink',
      btx_component_path: './test/SINK.metababel_test'
    }
  end
end
