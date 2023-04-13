require 'test/unit'
require 'open3'

module Assertions
  def assert_file_exists(file_path)
    assert(File.file?(file_path), "File '#{file_path}' does not exists.")
  end

  def run_command(cmd, refute = false)
    stdout_str, stderr_str, exit_code = Open3.capture3(cmd)

    if refute 
      raise Exception, stderr_str if exit_code == 0
    else
      raise Exception, stderr_str unless exit_code == 0
    end

    stdout_str
  end
end

def get_component_with_default_values(component)
  {
    btx_component_name: 'component_name',
    btx_component_path: "./test/#{component[:btx_component_type]}.metababel_test",
    btx_component_plugin_name: 'pluggin_name',
    btx_compile: true
  }.update(component)
end

def get_component_generation_command(component)
  arguments = {
    btx_component_path: '-o %s ',
    btx_component_type: '-t %s ',
    btx_component_name: '-c %s ',
    btx_component_plugin_name: '-p %s ',
    btx_component_downtream_model: '-d %s ',
    btx_component_upstream_model: '-u %s ',
    btx_component_usr_header_file: '-i %s '
  }

  command = 'ruby -I./lib ./bin/metababel '

  component.keys.grep(/_component_/) do |key|
    raise Exception, "Unsupported component option '#{key}'" unless arguments.key?(key)

    command += format(arguments[key], component[key])
  end

  command
end

def get_component_compilation_command(component)
  command = <<~TEXT
    ${CC:-cc} -o #{component[:btx_component_path]}/#{component[:btx_pluggin_name]}_#{component[:btx_component_name]}.so
               #{component[:btx_component_path]}/*.c #{component[:btx_component_path]}/metababel/*.c
               -I ./test/include/ -I #{component[:btx_component_path]}/#{' '}
               $(pkg-config --cflags babeltrace2) $(pkg-config --libs babeltrace2)#{' '}
               ${CFLAGS:='-Wall -Werror'} -fpic --shared
  TEXT
  command.split.join(' ')
end

def get_graph_execution_command(*components)
  components_paths = components.map { |c| c[:btx_component_path] }
  components_graph = components.map do |c|
    "--component=#{c[:btx_component_type].downcase}.#{c[:btx_component_plugin_name]}.#{c[:btx_component_name]}"
  end

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

def mock_user_callbacks(component)
  # See if we need to generate us callbacks.

  # If the user already define callancks do nothing
  return if component.key?(:btx_file_usr_callbacks)

  # We support only generation of SOURCE callbacks
  return unless component[:btx_component_type] == 'SOURCE'

  assert(component.include?(:btx_component_downtream_model),
         'Need to provide :btx_component_downtream_model when generating callbacks for SOURCE')
  opt_log = component.key?(:btx_log_path) ? '-i %<btx_log_path>s' : ''
  command = "ruby ./test/gen_source_callbacks.rb #{opt_log} -y %<btx_component_downtream_model>s -o %<btx_component_path>s/callbacks.c" % component
  run_command(command)
end

def run_and_stop(command, component, key)
  if component.fetch(key, false)
      run_command(command, true)
      return true
  end
  run_command(command)
  return false
end

module GenericTest
  include Assertions

  def test_run
    # Provide componenents default values
    sanitized_components = btx_components.map { |c| get_component_with_default_values(c) }

    sanitized_components.each do |c|
      return unless c[:btx_compile]

      # Validate files
      usr_assert_files(c)

      # Generate Metababel
      # metatabel_generation_command = get_component_generation_command(c)
      return if run_and_stop(get_component_generation_command(c),
                             c, :btx_metababel_generation_fail)

      # Copy user files
      c.keys.grep(/_file_usr/) do |key|
        assert_nothing_raised do
          FileUtils.cp(c[key], c[:btx_component_path])
        end
      end

      # Mock user callbacks
      mock_user_callbacks(c)

      # Compile
      return if run_and_stop(get_component_compilation_command(c), 
                             c, :btx_compilation_should_fail)
    end

    # Run
    assert_execution = btx_execution_validator || :run_command
    stdout_str = send(assert_execution, get_graph_execution_command(*sanitized_components))

    # Output validation
    return unless btx_output_validation

    expected_output = File.open(btx_output_validation, 'r').read
    assert_equal(expected_output, stdout_str)
  end
end

module VariableAccessor
  attr_reader :btx_components, :btx_execution_validator, :btx_output_validation

  def shutdown
    # Sanitize provide default attributes such as btx_component_path if not provided by the user.
    sanitized_components = @btx_components.map { |c| get_component_with_default_values(c) }
    sanitized_components.each do |c|
      FileUtils.remove_dir(c[:btx_component_path], true)
    end
  end
end

module VariableClassAccessor
  def btx_components
    self.class.btx_components
  end

  def btx_execution_validator
    self.class.btx_execution_validator
  end

  def btx_output_validation
    self.class.btx_output_validation
  end
end
