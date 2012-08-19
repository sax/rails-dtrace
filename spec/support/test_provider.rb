require 'rspec/mocks'

class TestProvider
  include RSpec::Mocks::ExampleMethods

  attr_reader :probes, :fired_probes

  def initialize
    super
    @probes = []
    @fired_probes = []
  end

  def enabled?
    @enabled
  end

  def probe(func, name, *args)
    p = double('probe', :probe_func => func, :probe_name => name, :probe_args => args, :enabled? => true)

    p.stub(:fire) do |*args|
      fired_probes << args
    end

    probes << p
    p
  end

  def disable
    @enabled = false
  end

  def enable
    @enabled = true
  end
end
