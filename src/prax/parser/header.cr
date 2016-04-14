module Prax
  class Parser
    class Header
      property name : String
      property values : Array(String)

      def initialize(@name, value)
        @values = [value]
      end

      def <<(value)
        values << value
      end

      def unshift(value)
        values.unshift(value)
      end

      def value
        values.first
      end

      def value=(value)
        values.clear
        values << value
        value
      end

      def ==(other)
        value == other
      end

      def to_s
        "#{name}: #{values.join(", ")}"
      end

      def to_i
        value.try(&.to_i) || 0
      end
    end

    class Headers < Array(Header)
      def prepend(name, value)
        if header = find { |h| h.name == name }
          header.unshift(value.to_s)
        else
          push(Header.new(name, value))
        end
      end

      def replace(name, value)
        if header = find { |h| h.name == name }
          header.value = value.to_s
        else
          push(Header.new(name, value))
        end
      end
    end
  end
end
