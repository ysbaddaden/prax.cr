require "uri"
require "./header"

module Prax
  class Parser
    class Request
      getter :method, :uri, :http_version, :headers

      def initialize(@method, @uri, @http_version)
        @headers = [] of Header
      end

      def add_header(name, value)
        if header = self.header(name)
          header << value
        else
          headers << Header.new(name, value)
        end
      end

      def header(name)
        headers.find { |header| header.name == name }
      end

      def host
        @host ||= if host = find_host
                    host.split(':', 2).first
                  else
                    raise InvalidRequest.new("missing host header")
                  end
      end

      def content_length
        header("Content-Length").to_i
      end

      def to_s
        "#{method} #{uri} #{http_version}\n" +
        headers.map(&.to_s).join("\n") +
        "\n\n"
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
