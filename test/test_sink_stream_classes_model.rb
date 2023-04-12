require 'base_test'

class TestSinkUserDefinedCastType < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downtream_model: './test/cases_sink_stream_classes_model/1.btx_model.yaml',
        btx_component_user_header_file: '1.usr_data_header.h',
        btx_command_gen_source: 'ruby ./test/gen_source.rb -i %{btx_log_path} -o %{btx_component_path}/callbacks.c',
        btx_log_path: './test/cases_sink_stream_classes_model/1.btx_log.txt',
        btx_file_usr_header_path: './test/cases_sink_stream_classes_model/1.usr_data_header.h',
      },
      {
        btx_component_type: 'SINK',
        btx_component_upstream_model: './test/cases_sink_stream_classes_model/1.btx_model.yaml',
        btx_component_user_header_file: '1.usr_data_header.h',
        btx_component_name: 'sink_pluggin',
        btx_component_pluggin_name: 'sink_component',
        btx_file_usr_header_path: './test/cases_sink_stream_classes_model/1.usr_data_header.h',
        btx_file_usr_callbacks: './test/cases_sink_stream_classes_model/1.callbacks.c'
      }
    ]
  end
end
