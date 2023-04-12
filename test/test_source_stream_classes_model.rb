require 'base_test'

class TestSourceNoCommonField < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [{
      btx_component_type: 'SOURCE',
      btx_component_downtream_model: './test/cases_source_stream_classes_model/1.btx_model.yaml',
      btx_command_gen_source: 'ruby ./test/gen_source.rb -i %{btx_log_path} -o %{btx_component_path}/callbacks.c',
      btx_log_path: './test/cases_source_stream_classes_model/1.btx_log.txt' 
    }]
  end
end

class TestSourceNoPayloadField < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [{
      btx_component_type: 'SOURCE',
      btx_component_downtream_model: './test/cases_source_stream_classes_model/2.btx_model.yaml',
      btx_command_gen_source: 'ruby ./test/gen_source.rb -i %{btx_log_path} -o %{btx_component_path}/callbacks.c',
      btx_log_path: './test/cases_source_stream_classes_model/2.btx_log.txt' 
    }]
  end
end

class TestSourceNoCommonNoPayloadFields < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [{
      btx_component_type: 'SOURCE',
      btx_component_downtream_model: './test/cases_source_stream_classes_model/3.btx_model.yaml',
      btx_log_path: './test/cases_source_stream_classes_model/3.btx_log.txt' 
    }]

    # Expected to fail at component generation
    @btx_generation_validator = :refute_command
  end
end

class TestSourceCommonPayloadFields < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [{
      btx_component_type: 'SOURCE',
      btx_component_downtream_model: './test/cases_source_stream_classes_model/4.btx_model.yaml',
      btx_command_gen_source: 'ruby ./test/gen_source.rb -i %{btx_log_path} -o %{btx_component_path}/callbacks.c',
      btx_log_path: './test/cases_source_stream_classes_model/4.btx_log.txt' 
    }]
  end
end

class TestSourceHundredFields < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [{
      btx_component_type: 'SOURCE',
      btx_component_downtream_model: './test/cases_source_stream_classes_model/5.btx_model.yaml',
      btx_command_gen_source: 'ruby ./test/gen_source.rb -i %{btx_log_path} -o %{btx_component_path}/callbacks.c',
      btx_log_path: './test/cases_source_stream_classes_model/5.btx_log.txt' 
    }]
  end
end

class TestSourceDetailsComparisonAllTypes < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [{
      btx_component_type: 'SOURCE',
      btx_component_downtream_model: './test/cases_source_stream_classes_model/6.btx_model.yaml',
      btx_command_gen_source: 'ruby ./test/gen_source.rb -o %{btx_component_path}/callbacks.c',
    },
    {
      btx_component_type: 'SINK',
      btx_component_name: 'details',
      btx_component_pluggin_name: 'text',
      # Prevent the component compilation which is not needed for babeltrace components.
      btx_compile: false
    }
  ]

    @btx_output_validation = './test/cases_source_stream_classes_model/6.btx_details.txt'
    # @btx_source_variables = {
    #   btx_model_path: './test/cases_source_stream_classes_model/6.btx_model.yaml',
    #   btx_log_path: './test/cases_source_stream_classes_model/0.btx_log.txt',
    #   btx_log_details_path: './test/cases_source_stream_classes_model/6.btx_details.txt',
    #   btx_component_name: 'source',
    #   btx_pluggin_name: 'metababel_tests',
    #   btx_component_path: './test/SOURCE.metababel_test'
    # }
  end
end

# class TestSourceDetailsComparisonIntegersNoFieldRange < Test::Unit::TestCase
#   include SourceTest
#   include SourceDetailSubtests
#   extend VariableAccessor
#   include VariableClassAccessor

#   def self.startup
#     @btx_source_variables = {
#       btx_model_path: './test/cases_source_stream_classes_model/7.btx_model.yaml',
#       btx_log_path: './test/cases_source_stream_classes_model/0.btx_log.txt',
#       btx_log_details_path: './test/cases_source_stream_classes_model/7.btx_details.txt',
#       btx_component_name: 'source',
#       btx_pluggin_name: 'metababel_tests',
#       btx_component_path: './test/SOURCE.metababel_test'
#     }
#   end
# end

# class TestSourceDetailsComparisonIntegers64DifferentBases < Test::Unit::TestCase
#   include SourceTest
#   include SourceDetailSubtests
#   extend VariableAccessor
#   include VariableClassAccessor

#   def self.startup
#     @btx_source_variables = {
#       btx_model_path: './test/cases_source_stream_classes_model/8.btx_model.yaml',
#       btx_log_path: './test/cases_source_stream_classes_model/0.btx_log.txt',
#       btx_log_details_path: './test/cases_source_stream_classes_model/8.btx_details.txt',
#       btx_component_name: 'source',
#       btx_pluggin_name: 'metababel_tests',
#       btx_component_path: './test/SOURCE.metababel_test'
#     }
#   end
# end

# class TestSourceDetailsComparisonIntegers32DifferentBases < Test::Unit::TestCase
#   include SourceTest
#   include SourceDetailSubtests
#   extend VariableAccessor
#   include VariableClassAccessor

#   def self.startup
#     @btx_source_variables = {
#       btx_model_path: './test/cases_source_stream_classes_model/9.btx_model.yaml',
#       btx_log_path: './test/cases_source_stream_classes_model/0.btx_log.txt',
#       btx_log_details_path: './test/cases_source_stream_classes_model/9.btx_details.txt',
#       btx_component_name: 'source',
#       btx_pluggin_name: 'metababel_tests',
#       btx_component_path: './test/SOURCE.metababel_test'
#     }
#   end
# end
