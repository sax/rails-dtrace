require 'usdt'

module DTrace
  module Provider
    class << self
      def new
        USDT::Provider.create :ruby, :rails
      end
    end
  end
end
