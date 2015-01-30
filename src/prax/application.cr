require "./path"
require "./errors"
require "./application/finders"
require "../kill"
require "../spawn"

module Prax
  XIP_IO = /\A(.+)\.(?:\d+\.){4}xip\.io\Z/

  class Application
    getter :name, :path, :last_accessed_at

    def initialize(name)
      @name = name.to_s
      @path = Path.new(@name)
      @last_accessed_at = Time.now
    end

    def touch
      @last_accessed_at = Time.now
    end

    def start
      return if started?

      if path.rack?
        return spawn_rack_application
      end

      #if path.shell?
      #  return spawn_shell_application
      #end
    end

    def stop
      if pid = @pid
        Process.kill(pid, Signal::TERM)
        @pid = nil
      end
    end

    def started?
      !stopped?
    end

    def stopped?
      @pid.nil?
    end

    def port
      @port ||= if path.forwarding?
                  path.port
                #elsif path.shell?
                #  find_available_port
                end.to_i
    end

    def connect
      socket = connect
      begin
        yield socket
      ensure
        socket.close
      end
    end

    private def connect
      if path.rack?
        UNIXSocket.new(path.socket_path)
      else
        TCPSocket.new("127.0.0.1", port)
      end
    end

    #private def find_available_port
    #  TCPServer.new(0).addr.ip_port
    #end

    private def spawn_rack_application
      cmd = [] of String
      cmd += ["bundle", "exec"] if path.gemfile?
      cmd += ["puma", "--bind", "unix:///tmp/prax_#{name}.sock", "--dir", path.to_s]

      File.open(File.join(ROOT, "_logs", "#{name}.log")) do |out|
        @pid = Process.spawn(cmd, out: out, err: out)
      end
    end

    #private def spawn_shell_application
    #  cmd = ["sh", path.to_s]
    #  env = { PORT: port }

    #  File.open(File.join(ROOT, "_logs", "#{name}.log")) do |out|
    #    @pid = Process.spawn(cmd, env: env, out: out, err: out)
    #  end
    #end
  end
end
