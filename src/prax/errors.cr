module Prax
  class Error < Exception
  end

  class NotImplementedError < Error
  end

  class ApplicationNotFound < Error
    getter name : String
    getter host : String

    def initialize(@name, @host)
      super ""
    end
  end

  class ErrorStartingApplication < Error
  end
end
