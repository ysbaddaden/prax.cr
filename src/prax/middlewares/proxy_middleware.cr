module Prax
  module Middlewares
    class ProxyMiddleware < Base
      def call(handler, &block)
        app = handler.app
        app.start unless app.started?
        app.restart if app.needs_restart?

        #Prax.logger.debug { "connecting to: #{app.name}" }
        app.connect { |server| proxy(handler, server) }
      end

      # TODO: stream response when Content-Length header isn't set (eg: Connection: close)
      # TODO: stream both sides (ie. support websockets)
      def proxy(handler, server)
        request, client = handler.request, handler.client
        Prax.logger.debug { "#{request.method} #{request.uri}" }

        server << "#{request.method} #{request.uri} #{request.http_version}\r\n"
        server << proxy_headers(request, handler.tcp_socket, handler.ssl?).map(&.to_s).join("\r\n")
        server << "\r\n\r\n"

        if (len = request.content_length) > 0
          copy_stream(client, server, len)
        end

        response = Parser.new(server).parse_response
        client << response.to_s

        if response.header("Transfer-Encoding") == "chunked"
          stream_chunked_response(server, client)
        elsif (len = response.content_length) > 0
          copy_stream(server, client, len)
        elsif response.header("Connection") == "close"
          copy_stream(server, client)
        else
          # TODO: read until EOF / connection close?
        end
      end

      # FIXME: should dup the headers to avoid altering the request
      def proxy_headers(request, socket, ssl)
        request.headers.replace("Connection", "close")
        # 'address.to_s' is to support Crystal versions before the issue in
        # https://github.com/crystal-lang/crystal/pull/3872 is resolved
        request.headers.prepend("X-Forwarded-For", socket.remote_address.address.to_s)
        request.headers.replace("X-Forwarded-Host", request.host)
        request.headers.replace("X-Forwarded-Proto", ssl ? "https" : "http")
        request.headers.prepend("X-Forwarded-Server", socket.local_address.address.to_s)
        request.headers
      end

      def stream_chunked_response(server, client)
        loop do
          break unless line = server.gets
          client << line
          count = line.strip.to_i(16)
          copy_stream(server, client, count + 2) # chunk + CRLF
          break if count == 0
        end
      end

      private def copy_stream(input, output, len)
        buffer = uninitialized UInt8[2048]

        while len > 0
          count = input.read(buffer.to_slice[0, Math.min(len, buffer.size)])
          break if count == 0

          output.write(buffer.to_slice[0, count])
          len -= count
        end
      end

      private def copy_stream(input, output)
        buffer = uninitialized UInt8[2048]

        loop do
          count = input.read(buffer.to_slice[0, buffer.size])
          break if count == 0
          output.write(buffer.to_slice[0, count])
        end
      end
    end
  end
end
