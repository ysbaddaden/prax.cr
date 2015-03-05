module Prax
  module Middlewares
    class ProxyMiddleware < Base
      def call(handler, &block)
        app = handler.app
        app.start unless app.started?
        app.restart if app.needs_restart?

        Prax.logger.debug "connecting to: #{app.name}"
        app.connect { |server| proxy(handler.request, handler.client, server) }
      end

      # TODO: stream response when Content-Length header isn't set (eg: Connection: close)
      # TODO: stream both sides (ie. support websockets)
      def proxy(request, client, server)
        Prax.logger.debug "#{request.method} #{request.uri}"

        server << "#{request.method} #{request.uri} #{request.http_version}\r\n"
        server << proxy_headers(request, client).map(&.to_s).join("\r\n")
        server << "\r\n\r\n"
        server << client.read(request.content_length) if request.content_length > 0

        response = Parser.new(server).parse_response
        client << response.to_s

        if response.header("Transfer-Encoding") == "chunked"
          stream_chunked_response(server, client)
        elsif response.content_length > 0
          client << server.read(response.content_length)
        else
          # TODO: read until EOF / connection close?
        end
      end

      # FIXME: should dup the headers to avoid altering the request
      def proxy_headers(request, client)
        request.headers.replace("Connection", "close")
        request.headers.prepend("X-Forwarded-For", client.peeraddr.ip_address)
        request.headers.replace("X-Forwarded-Host", request.host)
        request.headers.replace("X-Forwarded-Proto", "http") # TODO: https
        request.headers.prepend("X-Forwarded-Server", client.addr.ip_address)
        request.headers
      end

      def stream_chunked_response(server, client)
        loop do
          break unless line = server.gets

          client << line
          count = line.strip.to_i(16)

          if count == 0
            client << server.read(2) # CRLF
            break
          else
            client << server.read(count)
            client << server.read(2) # CRLF
          end
        end
      end
    end
  end
end
