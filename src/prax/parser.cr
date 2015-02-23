require "./parser/request"
require "./parser/response"

module Prax
  class Parser
    HEADER_RE = /([^:]+):\s+(.+)/

    class InvalidRequest < Exception
    end

    def initialize(@socket)
    end

    def parse_request
      method, uri, http_version = readline.split(/[ \t]+/)
      request = Request.new(method, uri, http_version)
      parse_headers(request)
      request
    #rescue ex : Errno
    #  raise InvalidRequest.new(ex.message)
    end

    def parse_response
      http_version, code, status = readline.split(/[ \t]+/, 3)
      response = Response.new(http_version, code, status)
      parse_headers(response)
      response
    #rescue ex : Errno
    #  raise InvalidRequest.new(ex.message)
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
        raise InvalidRequest.new("EOF")
      end
    end
  end
end
