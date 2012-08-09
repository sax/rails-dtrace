module DTrace
  class Railtie < Rails::Railtie

    initializer 'railtie.configure_rails.initialization' do
      DTrace::Responder.logger = Rails.logger
      ActiveSupport::Notifications.subscribe(/.*/, DTrace::Responder)
    end
  end
end
