require "uri"
require "./common"

module Prax
  class Parser
    class Request
      include Common

      getter :method, :uri, :http_version, :headers

      def initialize(@method, @uri, @http_version)
        @headers = [] of Header
      end

      def to_s
        "#{method} #{uri} #{http_version}\r\n" +
          headers.map(&.to_s).join("\r\n") +
          "\r\n\r\n"
      end

      def host
        @host ||= if host = find_host
                    host.split(':', 2).first
                  else
                    raise InvalidRequest.new("missing host header")
                  end
      end

      private def find_host
        if host_header = header("Host")
          host_header.value
        elsif uri = URI.parse(@uri)
          uri.host
        end
      end
    end
  end
end
