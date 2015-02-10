module Prax
  class Path
    def self.exists?(name)
      new(name).exists?
    end

    def initialize(name)
      @name = name.to_s
      @path = File.join(HOSTS, @name)
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

    def always_restart?
      File.exists?(always_restart_path)
    end

    def restart?
      File.exists?(restart_path)
    end

    def gemfile_path
      File.join(@path, "Gemfile")
    end

    def rackup_path
      File.join(@path, "config.ru")
    end

    def socket_path
      File.join(HOSTS, "_sockets", "#{@name}.sock")
    end

    def log_path
      File.join(HOSTS, "_logs", "#{@name}.log")
    end

    def restart_path
      File.join(@path, "tmp", "restart.txt")
    end

    def always_restart_path
      File.join(@path, "tmp", "always_restart.txt")
    end

    def port
      File.read(@path).to_i
    end

    def to_s
      @path
    end
  end
end
