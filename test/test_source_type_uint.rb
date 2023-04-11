require 'base_test'

class TestSourceTypeUInt64ZeroValue < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [{
      btx_component_type: 'SOURCE',
      btx_component_downtream_model: './test/cases_source_type_uint/1.btx_model.yaml',
      btx_command_gen_source: 'ruby ./test/gen_source.rb -i %{btx_log_path} -o %{btx_component_path}/callbacks.c',
      btx_log_path: './test/cases_source_type_uint/1.1.btx_log.txt' 
    }]

    # @btx_output_validation = './test/cases_source_type_uint/1.1.btx_log.txt'
    # @btx_generation_validator = :
    # @btx_compilation_validator = :
    # @btx_execution_validator = :
  end
end

class TestSourceTypeUInt64MaxValue < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [{
      btx_component_type: 'SOURCE',
      btx_component_downtream_model: './test/cases_source_type_uint/1.btx_model.yaml',
      btx_command_gen_source: 'ruby ./test/gen_source.rb -i %{btx_log_path} -y %{btx_component_downtream_model} -o %{btx_component_path}/callbacks.c',
      btx_log_path: './test/cases_source_type_uint/1.2.btx_log.txt' 
    }]
  end
end

class TestSourceTypeUInt32MaxValueNoCastType < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [{
      btx_component_type: 'SOURCE',
      btx_component_downtream_model: './test/cases_source_type_uint/2.btx_model.yaml',
      btx_command_gen_source: 'ruby ./test/gen_source.rb -i %{btx_log_path} -o %{btx_component_path}/callbacks.c',
      btx_log_path: './test/cases_source_type_uint/2.1.btx_log.txt' 
    }]
  end
end
