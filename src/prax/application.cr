require "./application/path"
require "./application/finders"
require "./application/spawner"

module Prax
  XIP_IO = /\A(.+)\.(?:\d+\.){4}xip\.io\Z/

  class Application
    getter name : String
    getter path : Path
    getter started_at : Time?
    getter last_accessed_at : Time
    @port : Int32?

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

      if path.restart? && (started_at = spawner.started_at)
        return started_at.to_unix < File.info(path.restart_path).modification_time.to_unix
      end

      false
    end

    def host
      @host ||= if path.forwarding?
                  path.host
                else # if path.rack? || path.shell?
                  "127.0.0.1"
                end
    end

    def port
      @port ||= if path.rack? || path.shell?
                  find_available_port
                elsif path.forwarding?
                  path.port
                end
    end

    def connect
      socket = TCPSocket.new(host, port)
      yield socket
    ensure
      socket.try(&.close)
    end

    def proxyable?
      path.rack? || path.forwarding? || path.shell?
    end

    private def find_available_port
      server = TCPServer.new(0)
      server.local_address.port.to_i
    ensure
      server.try(&.close)
    end

    # Sends a start, stop or restart commend to the spawner coroutine, then
    # waits for the coroutine to send a reply message.
    private def execute(command)
      channel = Channel::Unbuffered(String).new
      spawner.channel.send({channel, command})

      case message = channel.receive
      when "error"
        raise ErrorStartingApplication.new
      when "exception"
        raise spawner.exception
      end
    ensure
      channel.try(&.close)
    end

    private def spawner
      @spawner ||= Spawner.new(self)
    end
  end
end
