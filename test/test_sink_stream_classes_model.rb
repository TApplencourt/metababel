require 'base_test'

class TestSinkUserDefinedCastType < Test::Unit::TestCase
  include SinkTest
  include SourceCastTypeSubtests
  include SinkCastTypeSubtests
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_model_path: './test/cases_sink_stream_classes_model/1.btx_model.yaml',
      btx_log_path: './test/cases_sink_stream_classes_model/1.btx_log.txt',
      btx_component_name: 'source',
      btx_pluggin_name: 'metababel_source',
      btx_component_path: './test/SOURCE.metababel_test',
      btx_user_data_header_path: './test/cases_sink_stream_classes_model/1.user_data_header.h'
    }

    @btx_sink_variables = {
      btx_model_path: './test/cases_sink_stream_classes_model/1.btx_model.yaml',
      btx_callbacks_path: './test/cases_sink_stream_classes_model/1.callbacks.c',
      btx_component_name: 'sink',
      btx_pluggin_name: 'metababel_sink',
      btx_component_path: './test/SINK.metababel_test',
      btx_user_data_header_path: './test/cases_sink_stream_classes_model/1.user_data_header.h'
    }
  end
end
