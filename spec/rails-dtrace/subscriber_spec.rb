require 'spec_helper'
require 'rails-dtrace/subscriber'
require 'support/test_provider'
require 'support/test_logger'

describe DTrace::Subscriber, 'provider' do
  it "should return a new DTrace::Provider" do
    provider = double('provider')
    DTrace::Provider.should_receive(:new).and_return(provider)
    DTrace::Subscriber.provider.should == provider
  end
end

describe DTrace::Subscriber do
  subject { DTrace::Subscriber }

  let(:provider) {TestProvider.new}
  let(:logger) { TestLogger.new }

  before do
    subject.stub(:provider).and_return(provider)
    subject.stub(:logger).and_return(logger)
    subject.probes.clear
  end

  describe '.find_or_create_probe' do
    context "with a new notification" do
      let(:probe) { provider.probes.last }

      it "creates a DTrace probe" do
        expect {
          subject.find_or_create_probe("test.notification", "event")
        }.to change {
          provider.probes.size
        }.by 1
      end

      it "registers the notification name as the probe function" do
        subject.find_or_create_probe("test.notification", "event")
        probe.probe_func.should == "test.notification"
      end

      it "registers 'event' as the probe name" do
        subject.find_or_create_probe("test.notification", "event")
        probe.probe_name.should == "event"
      end

      it "registers probe argument types" do
        subject.find_or_create_probe("test.notification", "event")
        probe.probe_args.should == [:string, :string, :integer]
      end

      it "logs the new probe name" do
        subject.find_or_create_probe("test.notification", "event")
        logger.latest_entry.should == "Adding DTrace probe: test.notification::event"
      end

      it "enables the DTrace provider" do
        provider.should_not be_enabled
        subject.find_or_create_probe("test.notification", "event")
        provider.should be_enabled
      end

      it "disables the DTrace provider before re-enabling it" do
        subject.find_or_create_probe("first.notification", "event")
        provider.should_receive(:disable)
        subject.find_or_create_probe("second.notification", "event")
        provider.should be_enabled
      end
    end

    context "with an existing notification" do
      before do
        subject.find_or_create_probe("test.notification", "event")
      end

      it "should not create a new probe" do
        expect {
          subject.find_or_create_probe("test.notification", "event")
        }.not_to change {
          provider.probes.size
        }
      end
    end
  end

  describe '.call' do
    let(:probe) { double(:fire => true, :enabled? => false) }

    it "registers a probe with probe_name 'event'" do
      subject.should_receive(:find_or_create_probe).with("test.notification", "event").and_return(probe)
      subject.call("test.notification", nil, nil, "event-id", {})
    end

    it "fires the probe" do
      expect {
        subject.call("test.notification", nil, nil, "event-id", {})
      }.to change {
        provider.fired_probes.size
      }.by(1)

      provider.fired_probes.last.should == ["event-id", "{}", 0]
    end

    context "timestamps" do
      it "outputs time diff in nanoseconds" do
        start_time = Time.now
        end_time = start_time + 1

        subject.call("test.notification", start_time, end_time, "event-id", {})

        provider.fired_probes.last.should == ["event-id", "{}", 1000000000]
      end

      it "bounds time diffs by the maximum value of a C int" do
        start_time = Time.now
        end_time = start_time + 1000000

        subject.call("test.notification", start_time, end_time, "event-id", {})

        provider.fired_probes.last.should == ["event-id", "{}", 2147483647]
      end
    end
  end

  describe '.start' do
    let(:probe) { double(:fire => true, :enabled? => false) }

    it "registers a probe with probe_name 'entry'" do
      subject.should_receive(:find_or_create_probe).with("test.notification", "entry").and_return(probe)
      subject.start("test.notification", "event-id", {})
    end

    it "fires the probe" do
      expect {
        subject.start("test.notification", "event-id", {})
      }.to change {
        provider.fired_probes.size
      }.by(1)

      provider.fired_probes.last.should == ["event-id", "{}", 0]
    end
  end

  describe '.finish' do
    let(:probe) { double(:fire => true, :enabled? => false) }

    it "registers a probe with probe_name 'exit'" do
      subject.should_receive(:find_or_create_probe).with("test.notification", "exit").and_return(probe)
      subject.finish("test.notification", "event-id", {})
    end

    it "fires the probe" do
      expect {
        subject.finish("test.notification", "event-id", {})
      }.to change {
        provider.fired_probes.size
      }.by(1)

      provider.fired_probes.last.should == ["event-id", "{}", 0]
    end
  end
end
