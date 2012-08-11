module DTrace
  class Railtie < Rails::Railtie

    initializer 'railtie.configure_rails.initialization' do
      ActiveSupport::Notifications.subscribe(/.*/, DTrace::Responder)
    end
  end
end
