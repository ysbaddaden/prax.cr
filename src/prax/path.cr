module Prax
  class Path
    def self.exists?(name)
      new(name).exists?
    end

    def initialize(name)
      @name = name.to_s
      @path = File.join(ROOT, @name)
    end

    def rack?
      File.exists?(rackup_path)
    end

    def gemfile?
      File.exists?(gemfile_path)
    end

    def forwarding?
      port > 0
    end

    def shell?
      !forwarding?
    end

    def exists?
      File.exists?(@path)
    end

    def gemfile_path
      File.join(@path, "Gemfile")
    end

    def rackup_path
      File.join(@path, "config.ru")
    end

    def socket_path
      File.join(ROOT, "_sockets", "#{@name}.sock")
    end

    def port
      File.read(@path).to_i
    end

    def to_s
      @path
    end
  end
end
