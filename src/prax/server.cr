require "socket"
require "./handler"

module Prax
  class Server
    getter :servers

    def initialize
      @servers = [] of TCPServer
    end

    def run(http_port)
      puts "INFO: connecting to [::]:#{http_port}"
      servers << TCPServer.new("::", 20559)

      loop do
        ios = IO.select(servers)

        servers.each do |server|
          if ios.includes?(server)
            server.accept { |socket| Handler.new(socket) }
          end
        end
      end
    rescue ex
      stop
      raise ex
    end

    def stop
      servers.each(&.close)
    end
  end
end
