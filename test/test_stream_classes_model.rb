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

class TestSourceNoCommonNoPayloadFields < Test::Unit::TestCase
    include TestSourceBase
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/test_cases_stream_classes_model/3.btx_model.yaml',
            btx_target_log_path: './test/test_cases_stream_classes_model/3.btx_log.txt',
            btx_component_type: 'SOURCE',
            btx_component_name: 'source',
            btx_pluggin_name: 'metababel_tests',
            btx_component_path: './test/SOURCE.metababel_test'
        }
    end
end

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

class TestSourceDetailsComparisonAllTypes < Test::Unit::TestCase
    include TestSourceBase
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/test_cases_stream_classes_model/6.btx_model.yaml',
            btx_target_log_path: './test/test_cases_stream_classes_model/6.btx_details.txt',
            btx_component_type: 'SOURCE',
            btx_component_name: 'source',
            btx_pluggin_name: 'metababel_tests',
            btx_component_path: './test/SOURCE.metababel_test'
        }
    end

    # Generate a source with no messages.
    def subtest_generate_source_callbacks
        `ruby ./test/gen_source.rb -o #{btx_variables[:btx_component_path]}/callbacks.c`
        assert($?.success?)
    end

    # Compare with details in place of log.
    def subtest_run_source
        output = `babeltrace2 --plugin-path=#{btx_variables[:btx_component_path]} \
                              --component=#{btx_variables[:btx_component_type].downcase}.#{btx_variables[:btx_pluggin_name]}.#{btx_variables[:btx_component_name]} \
                              --component=sink.text.details`
        assert($?.success?)

        expected_output = File.open(btx_variables[:btx_target_log_path],"r").read
        assert_equal(expected_output, output)
    end
end

class TestSourceDetailsComparisonIntegersNoFieldRange < Test::Unit::TestCase
    include TestSourceBase
    extend VariableAccessor
    include VariableClassAccessor

    def self.startup
        @btx_variables = {
            btx_model_path: './test/test_cases_stream_classes_model/7.btx_model.yaml',
            btx_target_log_path: './test/test_cases_stream_classes_model/7.btx_details.txt',
            btx_component_type: 'SOURCE',
            btx_component_name: 'source',
            btx_pluggin_name: 'metababel_tests',
            btx_component_path: './test/SOURCE.metababel_test'
        }
    end

    # Generate a source with no messages.
    def subtest_generate_source_callbacks
        `ruby ./test/gen_source.rb -o #{btx_variables[:btx_component_path]}/callbacks.c`
        assert($?.success?)
    end

    # Compare with details in place of log.
    def subtest_run_source
        output = `babeltrace2 --plugin-path=#{btx_variables[:btx_component_path]} \
                              --component=#{btx_variables[:btx_component_type].downcase}.#{btx_variables[:btx_pluggin_name]}.#{btx_variables[:btx_component_name]} \
                              --component=sink.text.details`
        assert($?.success?)

        expected_output = File.open(btx_variables[:btx_target_log_path],"r").read
        assert_equal(expected_output, output)
    end
end