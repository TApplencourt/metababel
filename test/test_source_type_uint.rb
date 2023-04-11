require 'base_test'

class TestSourceTypeUInt64ZeroValue < Test::Unit::TestCase
  include SourceTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_source_variables = {
      btx_component_name: 'component_name',
      btx_component_type: 'SOURCE',
      btx_component_path: './test/SOURCE.metababel_test',
      btx_component_pluggin_name: 'pluggin_name',
      btx_component_downtream_model: './test/cases_source_type_uint/1.btx_model.yaml',
      btx_command_gen_source: 'ruby ./test/gen_source.rb -i %{btx_log_path} -o %{btx_component_path}/callbacks.c',
      btx_log_path: './test/cases_source_type_uint/1.1.btx_log.txt' 
    }
  end
end

# class TestSourceTypeUInt64MaxValue < Test::Unit::TestCase
#   include SourceTest
#   extend VariableAccessor
#   include VariableClassAccessor

#   def self.startup
#     @btx_source_variables = {
#       btx_model_path: './test/cases_source_type_uint/1.btx_model.yaml',
#       btx_log_path: './test/cases_source_type_uint/1.2.btx_log.txt',
#       btx_component_name: 'source',
#       btx_pluggin_name: 'metababel_tests',
#       btx_component_path: './test/SOURCE.metababel_test'
#     }
#   end
# end

# class TestSourceTypeUInt32MaxValueNoCastType < Test::Unit::TestCase
#   include SourceTest
#   extend VariableAccessor
#   include VariableClassAccessor

#   def self.startup
#     @btx_source_variables = {
#       btx_model_path: './test/cases_source_type_uint/2.btx_model.yaml',
#       btx_log_path: './test/cases_source_type_uint/2.1.btx_log.txt',
#       btx_component_name: 'source',
#       btx_pluggin_name: 'metababel_tests',
#       btx_component_path: './test/SOURCE.metababel_test'
#     }
#   end
# end
