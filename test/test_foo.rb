require 'test/unit'

class TestMetababelBin < Test::Unit::TestCase 
  def test_sanity
    `ruby -I./lib ./bin/metababel -h` 
  end
end

class TestMetababelSource < Test::Unit::TestCase
  self.test_order = :defined

  def test_creating_folder
    puts `ruby -I./lib ./bin/metababel -d ./test/1.stream_classes.yaml -t SOURCE -p metababel_tests -c source -o ./test/SOURCE.metababel`
  end

  def test_compiling
    Dir.chdir("./test/SOURCE.metababel") do
      puts `gcc -o metababel_tests_source.so *.c $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) -Wall -fpic --shared -I ../include/`
    end
  end

  def test_running
    log = `babeltrace2 --plugin-path=./test/SOURCE.metababel --component=source.metababel_tests.source`
    gold= <<EOF
test0: { test_integer_signed_32 = -10, integer_signed_signed_64 = 2147483648 }, { field0_integer_unsigned_32 = 4294967295 }
test1:with_colon: { test_integer_signed_32 = -11, integer_signed_signed_64 = 0 }, { field1_integer_unsigned_64 = 0, field2_string = "const char *" }
EOF
  assert_equal(log,gold)
  end
  
end
