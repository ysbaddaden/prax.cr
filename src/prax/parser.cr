require "./parser/request"

module Prax
  class Parser
    HEADER_RE = /([^:]+):\s+(.+)/

    class InvalidRequest < Exception
    end

    def initialize(@socket)
    end

    def parse
      method, uri, http_version = readline.split(/[ \t]+/)
      request = Request.new(method, uri, http_version)

      loop do
        break if (line = readline).empty?

        if match = HEADER_RE.match(line)
          request.add_header(match[1], match[2])
        else
          raise InvalidRequest.new("invalid header: '#{line}'")
        end
      end

      request
    rescue ex : Errno
      raise InvalidRequest.new(ex.message)
    end

    def readline
      if line = @socket.gets
        line.strip
      else
        raise InvalidRequest.new("EOF")
      end
    end
  end
end
