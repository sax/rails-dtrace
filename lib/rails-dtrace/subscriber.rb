require 'usdt'

module DTrace
  class Subscriber
    cattr_reader :probes, :provider

    @@provider = USDT::Provider.create :ruby, :rails
    @@probes = {}
    @@enabled = false

    class << self
      def logger
        @logger ||= Rails.logger if defined?(Rails)
      end

      attr_writer :logger

      # Rails 3.x define instruments as blocks that wrap code. When the code
      # finishes executing, subscribers are called with the start and end time.

      def call(notification, start_time, end_time, id, payload)
        fire_probe(notification, id, payload, 'event', start_time, end_time)
      end

      # Rails 4.x defines instruments in a different way, where #start is called
      # when the block begins and #finish is called when the block ends.

      def start(notification, id, payload)
        fire_probe(notification, id, payload, 'entry')
      end

      def finish(notification, id, payload)
        fire_probe(notification, id, payload, 'exit')
      end

      protected

      def find_or_create_probe(probe_func, probe_name)
        probe_id = "#{probe_func}::#{probe_name}"

        unless probes.keys.include?(probe_id)
          probe = provider.probe(probe_func, probe_name, :string, :string, :integer)
          probes[probe_id] = probe

          logger.debug "Adding DTrace probe: #{probe_id}"

          provider.disable if @@enabled
          provider.enable
          @@enabled = true
        end

        probes[probe_id]
      end

      private

      def fire_probe(notification, id, payload, type, start_time = nil, end_time = nil)
        probe = find_or_create_probe(notification, type)

        if probe.enabled?
          probe.fire id, payload.inspect, nsec_time_diff(start_time, end_time)
        end
      end

      def nsec_time_diff(start_time, end_time)
        return 0 unless start_time and end_time
        ((end_time - start_time) * 1000000000).to_i
      end
    end
  end
end
