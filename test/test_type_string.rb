require 'base_test'

class TestSourceTypeStringEmptyValue < Test::Unit::TestCase
    include TestSourceBase
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/test_cases_type_string/1.btx_model.yaml',
            btx_target_log_path: './test/test_cases_type_string/1.1.btx_log.txt',
            btx_component_type: 'SOURCE',
            btx_component_name: 'source',
            btx_pluggin_name: 'metababel_tests',
            btx_component_path: './test/SOURCE.metababel_test'
        }
    end
end

class TestSourceTypeStringLong < Test::Unit::TestCase
    include TestSourceBase
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/test_cases_type_string/1.btx_model.yaml',
            btx_target_log_path: './test/test_cases_type_string/1.2.btx_log.txt',
            btx_component_type: 'SOURCE',
            btx_component_name: 'source',
            btx_pluggin_name: 'metababel_tests',
            btx_component_path: './test/SOURCE.metababel_test'
        }
    end
end

class TestSourceTypeStringNestingPattern < Test::Unit::TestCase
    include TestSourceBase
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/test_cases_type_string/1.btx_model.yaml',
            btx_target_log_path: './test/test_cases_type_string/1.3.btx_log.txt',
            btx_component_type: 'SOURCE',
            btx_component_name: 'source',
            btx_pluggin_name: 'metababel_tests',
            btx_component_path: './test/SOURCE.metababel_test'
        }
    end
end