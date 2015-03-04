require "socket"
require "./handler"
require "../queue"

module Prax
  class Server
    getter :servers

    def initialize
      @servers = [] of TCPServer
      @queue = Queue(TCPSocket).new

      @workers = (1..16).map do
        Thread.new do
          loop { handle_client(@queue.pop) }
        end
      end
    end

    def run(http_port)
      Prax.logger.info "connecting to [::]:#{http_port}"
      servers << TCPServer.new("::", http_port)

      loop do
        ios = nil

        begin
          ios = IO.select(servers)
        rescue ex : Errno
          next if ex.errno == Errno::EINTR
          raise ex
        end
        next unless ios

        servers.each do |server|
          if ios.includes?(server)
            @queue.push(server.accept)
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

    private def handle_client(socket)
      Handler.new(socket)

      #loop do
      #  ios = nil

      #  begin
      #    ios = IO.select([socket], nil, nil, 15)
      #  rescue ex : Errno
      #    next if ex.errno == Errno::EINTR
      #    raise ex
      #  end

      #  unless ios
      #    Prax.logger.debug "closing idle connection"
      #    break
      #  end

      #  if ios.includes?(socket)
      #    handler = Handler.new(socket)
      #    break unless handler.keepalive?
      #  end
      #end

    rescue ex : Errno
      case ex.errno
      when Errno::EPIPE, Errno::ECONNRESET
      else
        debug_exception(ex)
      end

    #rescue ex : Parser::InvalidRequest
    #  Prax.logger.debug "invalid request: #{ex.message}"

    rescue ex
      debug_exception(ex)

    ensure
      socket.close
    end

    private def debug_exception(ex)
      Prax.logger.error "#{ex.message}\n  #{ex.backtrace.join("\n  ")}"
    end
  end
end
