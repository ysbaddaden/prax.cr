module Prax
  class Path
    def self.exists?(name)
      new(name).exists?
    end

    def initialize(name)
      @name = name.to_s
      @path = File.join(Prax.hosts_path, @name)
    end

    def rack?
      File.exists?(rackup_path)
    end

    def gemfile?
      File.exists?(gemfile_path)
    end

    def forwarding?
      File.file?(@path) && port > 0
    end

    def shell?
      File.file?(@path) && !forwarding?
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

    def env?
      File.exists?(env_path)
    end

    def public_path
      path = File.join(@path, "public")
      path = @path unless File.exists?(path) && rack?
      path
    end

    def gemfile_path
      File.join(@path, "Gemfile")
    end

    def rackup_path
      File.join(@path, "config.ru")
    end

    def log_path
      Dir.mkdir(Prax.logs_path) unless File.exists?(Prax.logs_path)
      File.join(Prax.logs_path, "#{@name}.log")
    end

    def restart_path
      File.join(@path, "tmp", "restart.txt")
    end

    def always_restart_path
      File.join(@path, "tmp", "always_restart.txt")
    end

    def env_path
      File.join(@path, ".env")
    end

    def port
      File.read(@path).to_i
    end

    def to_s
      @path
    end
  end
end
