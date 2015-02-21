module Prax
  module Middlewares
    class Base
      def call(handler)
        yield
      end
    end
  end
end
