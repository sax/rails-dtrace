require 'spec_helper'
require 'rails-dtrace/provider'

describe DTrace::Provider, '#new' do
  it "should create a new USDT::Provider" do
    provider = double("provider")
    USDT::Provider.should_receive(:create).with(:ruby, :rails).and_return(provider)
    DTrace::Provider.new.should == provider
  end
end
