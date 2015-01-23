module Prax
  class Error < Exception
  end

  class NotImplementedError < Error
  end

  class ApplicationNotFound < Error
    getter :name, :host

    def initialize(@name, @host)
      super ""
    end
  end
end
