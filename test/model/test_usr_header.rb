require 'base_test'

class UserDefinedCastType < Test::Unit::TestCase
  # Validate if the user can push messages and dispatch to callbacks using her own datatypes.
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/model/cases_usr_header/1.btx_model.yaml',
        btx_file_usr_header_path: './test/model/cases_usr_header/1.usr_header.h',
        btx_component_usr_header_file: '1.usr_header.h',
        btx_file_usr_callbacks: './test/model/cases_usr_header/1.source_callbacks.c',
      },
      {
        btx_component_type: 'SINK',
        btx_component_upstream_model: './test/model/cases_usr_header/1.btx_model.yaml',
        btx_file_usr_header_path: './test/model/cases_usr_header/1.usr_header.h',
        btx_component_usr_header_file: '1.usr_header.h',
        btx_file_usr_callbacks: './test/model/cases_usr_header/1.sink_callbacks.c',
      }
    ]
  end
end
