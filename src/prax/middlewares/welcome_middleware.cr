module Prax
  module Middlewares
    class WelcomeMiddleware < Base
      def call(handler)
        if LOCALHOSTS.includes?(handler.request.host)
          handler.reply 200, handler.views.welcome
        else
          yield
        end
      end
    end
  end
end
