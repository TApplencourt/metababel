require 'test/unit'
require 'open3'

module Assertions
  def assert_file_exists(file_path)
    assert(File.file?(file_path), "File '#{file_path}' does not exists.")
  end

  def assert_command(cmd)
    stdout_str, stderr_str, exit_code = Open3.capture3(cmd)
    raise Exception, stderr_str unless exit_code == 0
    stdout_str
  end

  def refute_command(cmd)
    _, stderr_str, exit_code = Open3.capture3(cmd)
    raise Exception, stderr_str if exit_code == 0
  end
end

def get_component_with_default_values(component)
  default = {
    btx_component_name: 'component_name',
    btx_component_path: "./test/#{component[:btx_component_type]}.metababel_test",
    btx_component_plugin_name: 'pluggin_name',
    btx_compile: true
  }
  
  default = default.update(component)

  # Infering if source_callbacks generation is needed.
  return default unless default[:btx_component_type] == 'SOURCE'
  return default if default.key?(:btx_file_usr_callbacks)

  opt_log = default.key?(:btx_log_path) ? '-i %{btx_log_path}' : ''
  default[:btx_command_gen_callbacks] = "ruby ./test/gen_source_callbacks.rb #{opt_log} -y %{btx_component_downtream_model} -o %{btx_component_path}/callbacks.c"

  default
end

def get_component_generation_command(component)
  arguments = {
    btx_component_path: '-o %s ',
    btx_component_type: '-t %s ',
    btx_component_name: '-c %s ',
    btx_component_plugin_name: '-p %s ',
    btx_component_downtream_model: '-d %s ',
    btx_component_upstream_model: '-u %s ',
    btx_component_user_header_file: '-i %s '
  }

  command = 'ruby -I./lib ./bin/metababel '

  component.keys.grep(/_component_/) do |key|
    raise Exception, "Unsupported component option '#{key}'" unless arguments.key?(key)
    command += arguments[key] % [ component[key] ]
  end

  command
end

def get_component_compilation_command(component)
  "${CC:-cc} -o #{component[:btx_component_path]}/#{component[:btx_pluggin_name]}_#{component[:btx_component_name]}.so #{component[:btx_component_path]}/*.c $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2) ${CFLAGS:='-Wall -Werror'} -fpic --shared -I ./test/include/"
end

def get_graph_execution_command(*components)
  components_paths = components.map { |c| c[:btx_component_path]  }
  components_graph = components.map { |c| "--component=#{c[:btx_component_type].downcase}.#{c[:btx_component_plugin_name]}.#{c[:btx_component_name]}" }
  
  "babeltrace2 --plugin-path=#{components_paths.join(':')} #{components_graph.join(' ')}"
end

def usr_assert_files(component)
  # Validate models
  component.keys.grep(/_model$/) do |key|
    assert_file_exists(component[key])
  end

  # Validate files
  component.keys.grep(/_file_/) do |key|
    assert_file_exists(component[key])
  end
end

def usr_copy_files(component)
  component.keys.grep(/_file_/) do |key|
    assert_nothing_raised do
      FileUtils.cp(component[key], component[:btx_component_path])
    end
  end
end

def usr_run_commands(component)
  component.keys.grep(/_command_/) do |key|
    command = component[key] % component
    assert_command(command)
  end
end 

module GenericTest
  include Assertions

  def test_run
    # Provide componenents default values
    sanitized_components = btx_components.map { |c|  get_component_with_default_values(c) }

    sanitized_components.each do |c|
      if c[:btx_compile] 
        # Validate files 
        usr_assert_files(c)
        
        # Generate
        assert_generation = btx_generation_validator || :assert_command
        send(assert_generation, get_component_generation_command(c))
        return unless assert_generation == :assert_command

        # Copy user files
        usr_copy_files(c)
        # Run user commands
        usr_run_commands(c)
        
        # Compile
        assert_compilation = btx_compilation_validator || :assert_command
        send(assert_compilation, get_component_compilation_command(c))
        return unless assert_compilation == :assert_command
      end
    end

    # Run
    assert_execution = btx_execution_validator || :assert_command
    stdout_str = send(assert_execution, get_graph_execution_command(*sanitized_components))

    # Output validation
    return unless btx_output_validation 
    expected_output = File.open(btx_output_validation, 'r').read
    assert_equal(expected_output,stdout_str) 
  end
end

module VariableAccessor
  attr_reader :btx_components, :btx_generation_validator, :btx_compilation_validator, :btx_execution_validator, :btx_output_validation
  def shutdown
    # Sanitize provide default attributes such as btx_component_path if not provided by the user.
    sanitized_components = @btx_components.map { |c|  get_component_with_default_values(c) }
    sanitized_components.each do |c|
      FileUtils.remove_dir(c[:btx_component_path], true)
    end
  end
end

module VariableClassAccessor
  def btx_components
    self.class.btx_components
  end

  # If this attribute is not defined in the test class
  # it will be nil once accesed on the test_run.
  def btx_generation_validator
    self.class.btx_generation_validator
  end

  def btx_compilation_validator
    self.class.btx_compilation_validator
  end

  def btx_execution_validator
    self.class.btx_execution_validator
  end

  def btx_output_validation
    self.class.btx_output_validation
  end
end
