require 'base_test'

# Empty strign test.
class TestSourceTypeString1 < Test::Unit::TestCase
    include TestSourceBase
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/cases_type_string/1.btx_model.yaml',
            btx_target_log_path: './test/cases_type_string/1.1.btx_log.txt',
            btx_component_type: 'SOURCE',
            btx_component_name: 'source',
            btx_pluggin_name: 'metababel_tests',
            btx_component_path: './test/SOURCE.metababel'
        }
    end 

    def self.shutdown
        FileUtils.remove_dir(@btx_variables[:btx_component_path],true)
    end
end

# 268 base64 string.
class TestSourceTypeString2 < Test::Unit::TestCase
    include TestSourceBase
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/cases_type_string/1.btx_model.yaml',
            btx_target_log_path: './test/cases_type_string/1.2.btx_log.txt',
            btx_component_type: 'SOURCE',
            btx_component_name: 'source',
            btx_pluggin_name: 'metababel_tests',
            btx_component_path: './test/SOURCE.metababel'
        }
    end 

    def self.shutdown
        FileUtils.remove_dir(@btx_variables[:btx_component_path],true)
    end
end
