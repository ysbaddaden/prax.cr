require "./application/path"
require "./application/finders"
require "./application/spawner"
require "../spawn"

module Prax
  XIP_IO = /\A(.+)\.(?:\d+\.){4}xip\.io\Z/

  class Application
    getter :name, :path, :started_at, :last_accessed_at

    def initialize(name)
      @name = name.to_s
      @path = Path.new(@name)
      @last_accessed_at = Time.now
      @mutex = Mutex.new
    end

    def touch
      @last_accessed_at = Time.now
    end

    def start(restart = false)
      @mutex.synchronize do
        return if started?
        action = restart ? "restarting" : "starting"

        if path.rack?
          Prax.logger.info "#{action} rack application: #{name} (port #{port})"
          spawner.spawn_rack_application
        elsif path.shell?
          Prax.logger.info "#{action} shell application: #{name} (port #{port})"
          spawner.spawn_shell_application
        end

        @started_at = Time.utc_now
      end
    end

    def stop(log = true)
      @mutex.synchronize do
        return if stopped?

        Prax.logger.info "killing application: #{name}" if log
        spawner.kill

        @started_at = nil
      end
    end

    def restart
      stop(log: false)
      start(restart: true)
    end

    def started?
      !!@started_at
    end

    def needs_restart?
      if path.always_restart?
        return true
      end

      if path.restart?
        return @started_at.to_i < File::Stat.new(path.restart_path).mtime.to_i
      end

      false
    end

    def stopped?
      !started?
    end

    def port
      @port ||= if path.rack? || path.shell?
                  find_available_port
                elsif path.forwarding?
                  path.port
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

    def connect
      #if path.rack?
      #  UNIXSocket.new(path.socket_path)
      #else
        TCPSocket.new("127.0.0.1", port)
      #end
    end

    def proxyable?
      port > 0
    end

    private def find_available_port
      server = TCPServer.new(0)
      server.addr.ip_port
    ensure
      server.close if server
    end

    private def spawner
      @spawner ||= Spawner.new(self)
    end
  end
end
