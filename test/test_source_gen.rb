require 'test/unit'

class TestMetababelSourceGen < Test::Unit::TestCase 
    self.test_order = :defined

    def self.startup
        system "ruby ./test/gen_yaml_and_log.rb \
            --fixed_cfields string,int64,int32,bool \
            --fixed_pfields string,int64,int32,bool \
            --fixed_string_value test \
            --fixed_integer_value 10 \
            --fixed_boolean_value true \
            --log ./test/btx_log.txt \
            --yaml ./test/btx_model.yaml"
    end

    def test_btx_model_exists
        success = system "cat ./test/btx_model.yaml > /dev/null"
        assert_equal true, success
    end 

    def test_btx_log_exists
        success = system "cat ./test/btx_log.txt > /dev/null"
        assert_equal true, success
    end 

    def test_metababel_bin
        success = system "ruby -I./lib ./bin/metababel -h > /dev/null"
        assert_equal true, success
    end 

    def test_generate_source
        success = system "ruby -I./lib ./bin/metababel -d ./test/btx_model.yaml -t SOURCE -p metababel_tests -c source -o ./test/SOURCE.metababel"
        assert_equal true, success
    end

    def test_generate_source_callbacks
        success = system "ruby ./test/gen_source.rb -t log -i ./test/btx_log.txt -o ./test/SOURCE.metababel/callbacks.c"
        assert_equal true, success
    end

    def test_compile_source
        success = system "gcc -o ./test/SOURCE.metababel/metababel_tests_source.so ./test/SOURCE.metababel/*.c $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -Wall -fpic --shared -I ./test/include/"
        assert_equal true, success
    end

    def test_run_source
        output = `babeltrace2 --plugin-path=./test/SOURCE.metababel --component=source.metababel_tests.source`
        expected_output = File.open("./test/btx_log.txt","r").read
        assert_equal expected_output, output
    end

    def self.shutdown
        system "rm -f ./test/btx_log.txt"
        system "rm -f ./test/btx_model.yaml"
        system "rm -rf ./test/SOURCE.metababel"
    end

end