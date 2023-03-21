require 'base_test'

class TestSourceNoCommonField < Test::Unit::TestCase
    include TestSourceBase
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/test_cases_stream_classes_model/1.btx_model.yaml',
            btx_target_log_path: './test/test_cases_stream_classes_model/1.btx_log.txt',
            btx_component_type: 'SOURCE',
            btx_component_name: 'source',
            btx_pluggin_name: 'metababel_tests',
            btx_component_path: './test/SOURCE.metababel_test'
        }
    end
end

class TestSourceNoPayloadField< Test::Unit::TestCase
    include TestSourceBase
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/test_cases_stream_classes_model/2.btx_model.yaml',
            btx_target_log_path: './test/test_cases_stream_classes_model/2.btx_log.txt',
            btx_component_type: 'SOURCE',
            btx_component_name: 'source',
            btx_pluggin_name: 'metababel_tests',
            btx_component_path: './test/SOURCE.metababel_test'
        }
    end
end

# class TestSourceNoCommonNoPayloadFields < Test::Unit::TestCase
#     include TestSourceBase
#     extend VariableAccessor
#     include VariableClassAccessor

#     def self.startup
#         @btx_variables = {
#             btx_model_path: './test/test_cases_stream_classes_model/3.btx_model.yaml',
#             btx_target_log_path: './test/test_cases_stream_classes_model/3.btx_log.txt',
#             btx_component_type: 'SOURCE',
#             btx_component_name: 'source',
#             btx_pluggin_name: 'metababel_tests',
#             btx_component_path: './test/SOURCE.metababel_test'
#         }
#     end
# end

class TestSourceCommonPayloadFields < Test::Unit::TestCase
    include TestSourceBase
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/test_cases_stream_classes_model/4.btx_model.yaml',
            btx_target_log_path: './test/test_cases_stream_classes_model/4.btx_log.txt',
            btx_component_type: 'SOURCE',
            btx_component_name: 'source',
            btx_pluggin_name: 'metababel_tests',
            btx_component_path: './test/SOURCE.metababel_test'
        }
    end
end

# Hundred common field, hundred payload fields, random types for fields.
class TestSourceHundredFields < Test::Unit::TestCase
    include TestSourceBase
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/test_cases_stream_classes_model/5.btx_model.yaml',
            btx_target_log_path: './test/test_cases_stream_classes_model/5.btx_log.txt',
            btx_component_type: 'SOURCE',
            btx_component_name: 'source',
            btx_pluggin_name: 'metababel_tests',
            btx_component_path: './test/SOURCE.metababel_test'
        }
    end
end