require 'base_test'

class TestSourceFilterSinkParamsEmpty < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_name: 'src',
        btx_component_plugin_name: 'src',
        btx_component_params: './test/cases_source_filter_sink_params/1.btx_params_model.yaml',
        btx_component_downstream_model: './test/cases_source_filter_sink_params/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/cases_source_filter_sink_params/1.callback.c',
        btx_log_path: './test/cases_source_filter_sink_params/1.btx_log.txt'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_name: 'flt',
        btx_component_plugin_name: 'flt',
        btx_component_params: './test/cases_source_filter_sink_params/1.btx_params_model.yaml',
        btx_component_downstream_model: './test/cases_source_filter_sink_params/1.btx_model.yaml',
        btx_component_upstream_model: './test/cases_source_filter_sink_params/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/cases_source_filter_sink_params/1.callback.c',
        btx_log_path: './test/cases_source_filter_sink_params/1.btx_log.txt'
      },
      {
        btx_component_type: 'SINK',
        btx_component_name: 'snk',
        btx_component_plugin_name: 'snk',
        btx_component_params: './test/cases_source_filter_sink_params/1.btx_params_model.yaml',
        btx_component_downstream_model: './test/cases_source_filter_sink_params/1.btx_model.yaml',
        btx_component_upstream_model: './test/cases_source_filter_sink_params/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/cases_source_filter_sink_params/1.callback.c',
        btx_log_path: './test/cases_source_filter_sink_params/1.btx_log.txt'
      }
    ]
  end
end
