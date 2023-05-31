require 'base_test'

 class TestSourceStateMachineAgain < Test::Unit::TestCase
   include GenericTest
   extend VariableAccessor
   include VariableClassAccessor

   def self.startup
    @btx_components = [
       {
         btx_component_type: 'SOURCE',
         btx_component_downstream_model: './test/cases_source_state_machine/1.btx_model.yaml',
         btx_file_usr_callbacks: './test/cases_source_state_machine/1.callbacks.c'
       }
     ]

     @btx_output_validation = './test/cases_source_state_machine/1.btx_log.txt'
   end
 end

class TestSourceStateMachinePushMessageInitialize < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_source_state_machine/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/cases_source_state_machine/2.callbacks.c'
      }
    ]

    @btx_output_validation = './test/cases_source_state_machine/1.btx_log.txt'
  end
end

 class TestSourceStateMachinePushMessageFinalize < Test::Unit::TestCase
   include GenericTest
   extend VariableAccessor
   include VariableClassAccessor

   def self.startup
     @btx_components = [
       {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_source_state_machine/1.btx_model.yaml',
        btx_file_usr_callbacks: './test/cases_source_state_machine/3.callbacks.c'
       }
     ]

     @btx_output_validation = './test/cases_source_state_machine/1.btx_log.txt'
   end
 end
