require 'usdt'

=begin

Problems:
* How do you dynamically enable/disable probes?
* Split name on '.' sucks
* Notifications include entry AND exit. Can we fire our own entry/exit probes?

=end

module DTrace
  class Responder
    cattr_reader :probes, :provider

    @@provider = USDT::Provider.create :ruby, :rails
    @@probes = {}
    @@enabled = false

    class << self
      def logger
        @logger ||= Rails.logger if defined?(Rails)
        @logger
      end

      attr_writer :logger

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
          probe = provider.probe(probe_func, probe_name, :string, :string)
          probes[probe_id] = probe

          logger.debug "Adding DTrace probe: #{probe_id}"

          provider.disable if @@enabled
          provider.enable
          @@enabled = true
        end

        probes[probe_id]
      end

      private

      def fire_probe(notification, id, payload, type)
        probe = find_or_create_probe(notification, type)

        if probe.enabled?
          probe.fire(id, payload.inspect)
        end
      end
    end
  end
end
