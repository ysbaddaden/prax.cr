require "socket"
require "openssl"
require "./handler"

class OpenSSL::SSL::Socket
  def write(slice : Slice(UInt8), count)
    LibSSL.ssl_write(@ssl, slice.pointer(count), count.to_i32)
  end
end

module Prax
  class Server
    getter :servers

    def initialize
      @servers = [] of TCPServer
    end

    def run(http_port, https_port)
      Prax.logger.info "binding to [::]:#{http_port}"
      servers << TCPServer.new("::", http_port)

      Prax.logger.info "binding to [::]:#{https_port}"
      servers << TCPServer.new("::", https_port)

      loop do
        ios = nil

        begin
          ios = IO.select(servers)
        rescue ex : Errno
          next if ex.errno == Errno::EINTR
          raise ex
        end
        next unless ios

        servers.each_with_index do |server, index|
          if ios.includes?(server)
            socket = server.accept
            Thread.new { handle_client(socket, index == 1) }
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

    private def ssl_context
      @ssl_context ||= OpenSSL::SSL::Context.new.tap do |ctx|
        ctx.certificate_chain = File.join(ENV["PRAX_ROOT"], "ssl", "server.crt")
        ctx.private_key = File.join(ENV["PRAX_ROOT"], "ssl", "server.key")
      end
    end

    private def handle_client(socket, ssl = false)
      if ssl
        ssl_socket = OpenSSL::SSL::Socket.new(socket, :server, ssl_context)
        Handler.new(ssl_socket)
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

    #rescue ex : Parser::InvalidRequest
    #  Prax.logger.debug "invalid request: #{ex.message}"

    rescue ex
      debug_exception(ex)

    ensure
      socket.close
      ssl_socket.try(&.close) if ssl
    end

    private def debug_exception(ex)
      Prax.logger.error "#{ex.message}\n  #{ex.backtrace.join("\n  ")}"
    end
  end
end
