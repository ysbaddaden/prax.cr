module Prax
  class Parser
    class Header
      property :name
      property :values

      def initialize(@name, value)
        @values = [value]
      end

      def <<(value)
        values << value
      end

      def value
        values.first
      end

      def ==(other)
        value == other
      end

      def to_s
        "#{name}: #{values.join(", ")}"
      end

      def to_i
        value.to_i
      end
    end
  end
end
