require "./common"

module Prax
  class Parser
    class Response
      include Common

      getter http_version : String
      getter code : String
      getter status : String
      getter headers : Array(Header)

      def initialize(@http_version, @code, @status)
        @headers = [] of Header
      end

      def to_s(io)
        io << http_version << ' ' << code << ' ' << status << "\r\n"
        headers.each(&.to_s(io))
        io << "\r\n"
      end
    end
  end
end
