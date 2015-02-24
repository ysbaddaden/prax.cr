require "./parser/request"
require "./parser/response"

module Prax
  class Parser
    REQUEST_LINE_RE = /\A([A-Z]+)[ \t]+(.+?)[ \t]+(HTTP\/[\d.]+)\Z/
    STATUS_LINE_RE = /\A(HTTP\/[\d.]+)[ \t]+(\d+)[ \t]+(.+?)\Z/
    HEADER_RE = /([^:]+):\s+(.+)/

    class InvalidRequest < Exception
    end

    def initialize(@socket)
    end

    def parse_request
      method, uri, http_version = parse(REQUEST_LINE_RE)
      request = Request.new(method, uri, http_version)
      parse_headers(request)
      request
    end

    def parse_response
      http_version, code, status = parse(STATUS_LINE_RE)
      response = Response.new(http_version, code, status)
      parse_headers(response)
      response
    end

    private def parse(re)
      line = readline

      if line =~ re
        {$1, $2, $3}
      else
        raise InvalidRequest.new("invalid status line: '#{line}'")
      end
    end

    private def parse_headers(object)
      loop do
        break if (line = readline).empty?

        if match = HEADER_RE.match(line)
          object.add_header(match[1], match[2])
        else
          raise InvalidRequest.new("invalid header: '#{line}'")
        end
      end
    end

    private def readline
      if line = @socket.gets
        line.strip
      else
        raise "EOF"
      end
    end
  end
end
