require "./parser"
require "./application"
require "./views"
require "./middleware"

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

    def initialize(@client)
      parser = Parser.new(client)
      @request = parser.parse_request
      Prax.run_middlewares(self)

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
        reply 404, views.proxy_error(request.host, app.port, ex)
      else
        Prax.logger.fatal "received errno exception (#{ex.errno}) #{ex.message}:\n  #{ex.backtrace.join("  \n")}"
        reply 500, ex.to_s
      end

    rescue ex
      Prax.logger.fatal "received exception: #{ex.message}\n  #{ex.backtrace.join("  \n")}"
      reply 500, ex.to_s
    end

    def app
      @app ||= Application.search(request.host)
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

    def reply(code, headers = nil)
      status = STATUSES.fetch(code)

      headers ||= [] of String
      headers << "Connection: close"

      client << "#{request.http_version} #{code} #{status}\r\n"
      client << headers.join("\r\n").to_s
      client << "\r\n\r\n"

      yield
    end
  end
end
