require "./parser"
require "./application"
require "./views"

module Prax
  STATUSES = {
    200 => "OK",
    400 => "BAD REQUEST",
    404 => "NOT FOUND",
    500 => "INTERNAL SERVER ERROR",
    501 => "NOT IMPLEMENTED ERROR",
  }
  LOCALHOSTS = [
    "127.0.0.1",
    "localhost",
    "::1",
    "ip6-localhost",
  ]

  class Handler
    getter :request, :client

    # TODO: forward the request to the application
    # TODO: forward the response back to the client
    def initialize(@client)
      parser = Parser.new(client)
      @request = parser.parse

      host = request.host

      if LOCALHOSTS.includes?(request.host)
        reply 200, views.welcome
        return
      end

      app = @app = Application.search(host)
      app.start

      Prax.logger.debug "Connecting to: #{app.name}"
      app.connect { |server| proxy(server) }

    rescue ex : ApplicationNotFound
      reply 404, views.application_not_found(ex.name, ex.host)

    rescue ex : ErrorStartingApplication
      reply 500, views.error_starting_application(app)

    rescue ex : NotImplementedError
      reply 501, "Not Implemented #{ex.message}"

    rescue ex : Parser::InvalidRequest
      reply 400, "Bad Request: #{ex.message}"

    rescue ex : Errno
      case ex.errno
      when Errno::ECONNREFUSED
        reply 404, views.proxy_error(request.host, app.port, ex) if app
      else
        reply 500, ex.to_s
      end

    rescue ex
      reply 500, ex.to_s
    end

    # TODO: stream response when Content-Length header isn't set (eg: Connection: close)
    # TODO: stream both sides (ie. support websockets)
    def proxy(server)
      Prax.logger.debug "#{request.method} #{request.uri}"

      server << request.to_s
      server << client.read(request.content_length) if request.content_length > 0

      response = Parser.new(server).parse
      client << response.to_s

      if response.header("Transfer-Encoding") == "chunked"
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
      elsif response.content_length > 0
        client << server.read(response.content_length)
      else
        # TODO: read until EOF / connection close?
      end
    end

    def views
      @views ||= Views.new
    end

    def reply(code, body = nil)
      status = STATUSES.fetch(code)
      body = body ? body + "\n" : ""

      client << "#{request.http_version} #{code} #{status}\r\n"
      client << "Connection: close\r\n"
      client << "Content-Length: #{body.bytesize}\r\n"
      client << "\r\n"
      client << body
      client.flush
    end
  end
end
