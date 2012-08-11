module DTrace
  class Railtie < Rails::Railtie

    initializer 'railtie.configure_rails.initialization' do
      ActiveSupport::Notifications.subscribe(/.*/, DTrace::Subscriber)
    end
  end
end
