require 'base_test'

# No common field test.
class TestSourceFields1 < Test::Unit::TestCase
    include TestSourceBase
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/cases_fields/1.btx_model.yaml',
            btx_target_log_path: './test/cases_fields/1.btx_log.txt',
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

# No payload field test.
class TestSourceFields2 < Test::Unit::TestCase
    include TestSourceBase
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/cases_fields/2.btx_model.yaml',
            btx_target_log_path: './test/cases_fields/2.btx_log.txt',
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

# No common field, no payload test
class TestSourceFields3 < Test::Unit::TestCase
    include TestSourceBase
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/cases_fields/3.btx_model.yaml',
            btx_target_log_path: './test/cases_fields/3.btx_log.txt',
            btx_component_type: 'SOURCE',
            btx_component_name: 'source',
            btx_pluggin_name: 'metababel_tests',
            btx_component_path: './test/SOURCE.metababel'
        }
    end 

    # Should fail at compile.
    def compile_source
        `cc -o #{btx_variables[:btx_component_path]}/#{btx_variables[:btx_pluggin_name]}_#{btx_variables[:btx_component_name]}.so #{btx_variables[:btx_component_path]}/*.c $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -Wall -fpic --shared -I ./test/include/ >& /dev/null`
        assert(!$?.success?)
    end

    # Should fail at run.
    def run_source
        output = `babeltrace2 --plugin-path=#{btx_variables[:btx_component_path]} --component=#{btx_variables[:btx_component_type].downcase}.#{btx_variables[:btx_pluggin_name]}.#{btx_variables[:btx_component_name]} >& /dev/null`
        assert(!$?.success?)

        expected_output = File.open(btx_variables[:btx_target_log_path],"r").read
        assert_not_equal(expected_output, output)
    end

    def self.shutdown
        FileUtils.remove_dir(@btx_variables[:btx_component_path],true)
    end
end

# Common field, payload field test.
class TestSourceFields4 < Test::Unit::TestCase
    include TestSourceBase
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/cases_fields/4.btx_model.yaml',
            btx_target_log_path: './test/cases_fields/4.btx_log.txt',
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

# Hundred common field, hundred payload fields, random types for fields.
class TestSourceFields5 < Test::Unit::TestCase
    include TestSourceBase
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/cases_fields/5.btx_model.yaml',
            btx_target_log_path: './test/cases_fields/5.btx_log.txt',
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