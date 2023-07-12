require 'base_test'

# class TestFilterMatchingCallbacksCalled < Test::Unit::TestCase
#   # Validate the proper calling of both regular and matching callbacks.
#   # Regular callbacks dispatch event_1 while matching callbacks dispatch
#   # event_2. 

#   include GenericTest
#   extend VariableAccessor
#   include VariableClassAccessor

#   def self.startup
#     @btx_components = [
#       {
#         btx_component_type: 'SOURCE',
#         btx_component_downstream_model: './test/cases_matching_callbacks/1.btx_model.yaml',
#         btx_log_path: './test/cases_matching_callbacks/1.btx_log.txt'
#       },
#       {
#         btx_component_type: 'FILTER',
#         btx_component_upstream_model: './test/cases_matching_callbacks/1.btx_model.yaml',
#         btx_component_downstream_model: './test/cases_matching_callbacks/1.btx_model.yaml',
#         btx_component_callbacks: './test/cases_matching_callbacks/1.btx_callbacks.yaml',
#         btx_file_usr_callbacks: './test/cases_matching_callbacks/1.callbacks.c'
#       }
#     ]
#   end
# end

class TestFilterMatchingCallbacksCalledWithTimeStamp < Test::Unit::TestCase
  # Validate the _timestamp is passed properly in matching callbacks.
  # Since this validates downstream.c we not need to perform the same 
  # test for sink components. 

  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SOURCE',
        btx_component_downstream_model: './test/cases_matching_callbacks/2.btx_model.yaml',
        btx_log_path: './test/cases_matching_callbacks/2.btx_log.txt'
      },
      {
        btx_component_type: 'FILTER',
        btx_component_upstream_model: './test/cases_matching_callbacks/2.btx_model.yaml',
        btx_component_downstream_model: './test/cases_matching_callbacks/2.btx_model.yaml',
        btx_component_callbacks: './test/cases_matching_callbacks/2.btx_callbacks.yaml',
        btx_file_usr_callbacks: './test/cases_matching_callbacks/2.callbacks.c'
      }
    ]

    @btx_output_validation = './test/cases_matching_callbacks/2.btx_log.txt'
  end
end