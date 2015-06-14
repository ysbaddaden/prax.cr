require "./application/path"
require "./application/finders"
require "./application/spawner"

module Prax
  XIP_IO = /\A(.+)\.(?:\d+\.){4}xip\.io\Z/

  class Application
    getter :name, :path, :started_at, :last_accessed_at

    def initialize(name)
      @name = name.to_s
      @path = Path.new(@name)
      @last_accessed_at = Time.now
    end

    def touch
      @last_accessed_at = Time.now
    end

    def start
      execute("start")
    end

    def stop
      execute("stop")
    end

    def restart
      execute("restart")
    end

    def started?
      spawner.started?
    end

    def stopped?
      spawner.stopped?
    end

    def needs_restart?
      if path.always_restart?
        return true
      end

      if path.restart? && spawner.started_at
        return spawner.started_at.to_i < File::Stat.new(path.restart_path).mtime.to_i
      end

      false
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

    # Sends a start, stop or restart commend to the spawner coroutine, then
    # waits for the coroutine to send a reply message.
    private def execute(command)
      channel = UnbufferedChannel(String).new
      spawner.channel.send({channel, command})

      case message = channel.receive
      when "error"
        raise ErrorStartingApplication.new
      when "exception"
        raise spawner.exception
      end
    end

    private def spawner
      @spawner ||= Spawner.new(self)
    end
  end
end
