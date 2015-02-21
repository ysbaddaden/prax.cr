require "./header"

module Prax
  class Parser
    module Common
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

      def content_length
        header("Content-Length").to_i
      end
    end
  end
end
