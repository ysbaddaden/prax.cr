require "socket"
require "openssl"
require "./handler"

module Prax
  class Server
    getter servers

    def initialize
      @servers = [] of TCPServer
    end

    def run(http_port, https_port)
      Prax.logger.info "binding to [::]:#{http_port}"
      servers << TCPServer.new("::", http_port)

      if ssl_configured?
        Prax.logger.info "binding to [::]:#{https_port}"
        servers << TCPServer.new("::", https_port)
      end

      # each server accepts connections in its own fiber
      servers.each_with_index do |server, index|
        spawn do
          loop do
            spawn handle_client(server.accept, index == 1)
          end
        end
      end

      # blocks execution without blocking io
      loop { sleep 10000 }
    rescue ex
      stop
      raise ex
    end

    def stop
      servers.each(&.close)
    end

    # TODO: enable keepalive support
    private def handle_client(socket, ssl)
      if ssl
        ssl_socket = OpenSSL::SSL::Socket.new(socket, :server, ssl_context)
        Handler.new(ssl_socket, socket)
      else
        Handler.new(socket)
      end

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

    rescue ex : IO::EOFError
      # silence

    rescue ex
      debug_exception(ex)

    ensure
      ssl_socket.try(&.close) if ssl_socket
      socket.close
    end

    private def debug_exception(ex)
      Prax.logger.error "#{ex.message}\n  #{ex.backtrace.join("\n  ")}"
    end

    private def ssl_configured?
      File.exists?(ssl_path(:key)) && File.exists?(ssl_path(:crt))
    end

    @ssl_context : OpenSSL::SSL::Context?

    private def ssl_context
      @ssl_context ||= OpenSSL::SSL::Context.new.tap do |ctx|
        ctx.certificate_chain = ssl_path(:crt)
        ctx.private_key = ssl_path(:key)
      end
    end

    private def ssl_path(extname)
      File.join(Prax.root_path, "ssl", "server.#{extname}")
    end
  end
end
