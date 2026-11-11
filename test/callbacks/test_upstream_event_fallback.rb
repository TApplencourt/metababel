require 'base_test'

# The upstream event fallback: an upstream event no callback is registered for goes to the fallback
# callback (--enable-additional-callbacks upstream_event_fallback) if one is registered, else a filter
# applies --upstream-event-fallback (passthrough or drop) and a sink drops it.

FALLBACK_CASES = './test/callbacks/cases_upstream_event_fallback'

FALLBACK_SOURCE = {
  btx_component_type: 'SOURCE',
  btx_component_downstream_model: "#{FALLBACK_CASES}/1.btx_model.yaml",
  btx_log_path: "#{FALLBACK_CASES}/1.btx_log.txt",
}.freeze

def fallback_filter(callbacks, **options)
  {
    btx_component_type: 'FILTER',
    btx_component_upstream_model: "#{FALLBACK_CASES}/1.btx_model.yaml",
    btx_component_downstream_model: "#{FALLBACK_CASES}/1.btx_model.yaml",
    btx_file_usr_callbacks: "#{FALLBACK_CASES}/#{callbacks}",
    btx_component_enable_additional_callbacks: 'upstream_event_fallback',
  }.update(options)
end

# A sink with a model: event_b is in the model but has no callback, so it goes to the fallback.
class TestUpstreamEventFallbackSink < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      FALLBACK_SOURCE,
      {
        btx_component_type: 'SINK',
        btx_component_upstream_model: "#{FALLBACK_CASES}/1.btx_model.yaml",
        btx_file_usr_callbacks: "#{FALLBACK_CASES}/sink_callbacks.c",
        btx_component_enable_additional_callbacks: 'upstream_event_fallback',
      },
    ]
    @btx_output_validation = "#{FALLBACK_CASES}/sink.out"
  end
end

# A sink without a model: every event goes to the fallback.
class TestUpstreamEventFallbackSinkWithoutModel < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      FALLBACK_SOURCE,
      {
        btx_component_type: 'SINK',
        btx_file_usr_callbacks: "#{FALLBACK_CASES}/sink_no_model_callbacks.c",
        btx_component_enable_additional_callbacks: 'upstream_event_fallback',
      },
    ]
    @btx_output_validation = "#{FALLBACK_CASES}/sink_no_model.out"
  end
end

# A filter: event_a is dispatched, the fallback forwards the first event_b and drops the second.
class TestUpstreamEventFallbackFilter < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [FALLBACK_SOURCE, fallback_filter('filter_callbacks.c')]
    @btx_output_validation = "#{FALLBACK_CASES}/filter.out"
  end
end

# What the fallback forwards goes through the downstream message callback, which drops the first event.
class TestUpstreamEventFallbackFilterDownstreamMessage < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [FALLBACK_SOURCE,
                       fallback_filter('filter_downstream_callbacks.c',
                                       btx_component_enable_additional_callbacks: %w[upstream_event_fallback
                                                                                  downstream_message])]
    @btx_output_validation = "#{FALLBACK_CASES}/filter_downstream.out"
  end
end

# No fallback callback registered: --upstream-event-fallback applies (default passthrough).
class TestUpstreamEventFallbackFilterUnregistered < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [FALLBACK_SOURCE, fallback_filter('filter_unregistered_callbacks.c')]
    @btx_output_validation = "#{FALLBACK_CASES}/filter_unregistered.out"
  end
end

# A registered fallback callback wins over --upstream-event-fallback drop.
class TestUpstreamEventFallbackFilterDropCallback < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [FALLBACK_SOURCE,
                       fallback_filter('filter_callbacks.c', btx_component_upstream_event_fallback: 'drop')]
    @btx_output_validation = "#{FALLBACK_CASES}/filter.out"
  end
end

# No fallback callback registered and --upstream-event-fallback drop: everything is dropped.
class TestUpstreamEventFallbackFilterDropUnregistered < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [FALLBACK_SOURCE,
                       fallback_filter('filter_unregistered_callbacks.c', btx_component_upstream_event_fallback: 'drop')]
    @btx_output_validation = "#{FALLBACK_CASES}/filter_drop_unregistered.out"
  end
end

# A source has no upstream: no upstream event fallback callback.
class TestUpstreamEventFallbackCallbackSourceInvalid < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [FALLBACK_SOURCE.merge(btx_component_enable_additional_callbacks: 'upstream_event_fallback',
                                             btx_metababel_generation_fail: true)]
  end
end

# Not an additional callback.
class TestEnableAdditionalCallbacksUnknownInvalid < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [FALLBACK_SOURCE, fallback_filter('filter_callbacks.c',
                                                        btx_component_enable_additional_callbacks: 'event_a',
                                                        btx_metababel_generation_fail: true)]
  end
end

# A source has no upstream.
class TestUpstreamEventFallbackSourceInvalid < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [FALLBACK_SOURCE.merge(btx_component_upstream_event_fallback: 'drop',
                                             btx_metababel_generation_fail: true)]
  end
end

# --upstream-event-fallback is for a filter only: a sink always drops.
class TestUpstreamEventFallbackSinkInvalid < Test::Unit::TestCase
  include GenericTest
  extend VariableAccessor
  include VariableClassAccessor

  def self.startup
    @btx_components = [
      {
        btx_component_type: 'SINK',
        btx_component_upstream_model: "#{FALLBACK_CASES}/1.btx_model.yaml",
        btx_component_upstream_event_fallback: 'drop',
        btx_metababel_generation_fail: true,
      },
    ]
  end
end
