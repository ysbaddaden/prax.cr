require "uri"
require "./common"

module Prax
  class Parser
    class Request
      include Common

      getter method : String
      getter uri : String
      getter http_version : String
      getter headers : Headers
      @host : String?

      def initialize(@method, @uri, @http_version)
        @headers = Headers.new
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
