require "socket"
require "../select"
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
        IO.select(servers) do |rd|
          servers.each do |server|
            if rd.is_set(server)
              server.accept { |socket| Handler.new(socket) }
            end
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
