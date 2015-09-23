require "./middlewares/base"
require "./middlewares/welcome_middleware"
require "./middlewares/public_file_middleware"
require "./middlewares/proxy_middleware"

module Prax
  class Middleware
    getter :middlewares

    def initialize
      @middlewares = [] of Middlewares::Base
      yield self
    end

    def add(middleware)
      middlewares << middleware
    end

    def run(handler)
      middlewares.each do |middleware|
        continue = false
        middleware.call(handler) { continue = true }
        break unless continue
      end
    end
  end

  @@middlewares = Middleware.new do |m|
    m.add Middlewares::WelcomeMiddleware.new
    m.add Middlewares::PublicFileMiddleware.new
    m.add Middlewares::ProxyMiddleware.new
  end

  def self.run_middlewares(handler)
    @@middlewares.run(handler)
  end
end
