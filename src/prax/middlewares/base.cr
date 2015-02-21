module Prax
  module Middlewares
    class Base
      def call(handler)
        Prax.logger.debug "Base: #{handler}"
        yield
      end
    end
  end
end
