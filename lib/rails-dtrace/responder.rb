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
    cattr_writer :logger

    @@provider = USDT::Provider.create :ruby, :rails
    @@probes = {}
    @@enabled = false

    def self.logger
      @@logger || Logger.new
    end

    def self.call(name, started, finished, unique_id, payload)
      unless probes.keys.include?(name)
        func_name, probe_name = name.split('.')
        p = @@provider.probe(func_name, probe_name, :integer, :integer, :string, :string)
        probes[name] = p
        logger.debug "Adding dtrace probe: #{name}"
        @@provider.disable if @@enabled
        @@provider.enable
        @@enabled = true
      end

      if probes[name].enabled?
        probes[name].fire(started.to_i, finished.to_i, unique_id, payload.inspect)
      end
    end
  end
end
