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
    getter :request, :socket

    # TODO: forward the request to the application
    # TODO: forward the response back to the client
    def initialize(@socket)
      parser = Parser.new(socket)
      @request = parser.parse

      host = request.host

      if LOCALHOSTS.includes?(request.host)
        reply 200, Views.new.welcome
        return
      end

      app = @app = Application.search(host)
      app.start
      #reply app.proxy(request)

      body = "The #{app.name} application is configured, but this version of Prax is nothing but a stub...\n"
      reply 501, body

    rescue ex : ApplicationNotFound
      reply 404, Views.new.application_not_found(ex.name, ex.host)

    rescue ex : NotImplementedError
      reply 501, "Not Implemented #{ex.message}"

    rescue ex : Parser::InvalidRequest
      reply 400, "Bad Request: #{ex.message}"

    rescue ex
      reply 500, ex.to_s
    end

    def reply(response)
    end

    def reply(code, body = nil)
      status = STATUSES.fetch(code)
      body = body ? body + "\n" : ""

      socket << "#{request.http_version} #{code} #{status}\r\n"
      socket << "Connection: close\r\n"
      socket << "Content-Length: #{body.bytesize}\r\n"
      socket << "\r\n"
      socket << body
      socket.flush
    end
  end
end
