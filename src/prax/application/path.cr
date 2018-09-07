module Prax
  class Path
    def self.exists?(name)
      new(name).exists?
    end

    @name : String
    @path : String

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

    def praxrc?
      File.exists?(praxrc_path)
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

    def public_path
      path = File.join(@path, "public")
      path = @path unless File.exists?(path) && rack?
      path
    end

    def gemfile_path
      File.join(@path, "Gemfile")
    end

    def praxrc_path
      File.join(@path, ".praxrc")
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

    def host
      str = File.read(@path).strip

      if str.starts_with?('[')
        if bracket = str.index(']')
          return str[1 ... bracket]
        end
      end

      if colon = str.index(':')
        return str[0 ... colon]
      end

      "127.0.0.1"
    end

    def port
      str = File.read(@path).strip

      if bracket = str.index(']')
        str = str[(bracket + 1) .. -1]
      end

      if colon = str.index(':')
        str = str[(colon + 1) .. -1]
      end

      str.to_i
    end

    def to_s
      @path
    end
  end
end
