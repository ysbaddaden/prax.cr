require "socket"
require "./handler"

module Prax
  class Server
    getter :servers

    def initialize
      @servers = [] of TCPServer
    end

    def run(http_port)
      Prax.logger.info "connecting to [::]:#{http_port}"
      servers << TCPServer.new("::", HTTP_PORT)

      loop do
        ios = nil

        begin
          ios = IO.select(servers)
        rescue ex : Errno
          if ex.errno == Errno::EINTR
            Prax.logger.debug "rescued Errno::EINTR in IO.select"
            next
          else
            raise ex
          end
        end
        next unless ios

        servers.each do |server|
          if ios.includes?(server)
            socket = server.accept

            Thread.new do
              begin
                Handler.new(socket)
              rescue ex : Errno
                case ex.errno
                when Errno::EPIPE
                  Prax.logger.debug "rescued broken pipe"
                else
                  raise ex
                end
              ensure
                socket.close
              end
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
