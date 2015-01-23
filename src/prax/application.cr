require "./path"
require "./errors"
require "./application/finders"
require "../kill"

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

    # TODO: spawn the rack application (if)
    # TODO: spawn the shell application (if, providing a PORT env variable)
    def start
      if stopped?
        if path.rack?
          raise NotImplementedError.new("spawning rack application")
        elsif path.shell?
          raise NotImplementedError.new("spawning shell applications")
        end
      end
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
                elsif path.shell?
                  find_available_port
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

    private def find_available_port
      TCPServer.new(0).addr.ip_port
    end
  end
end
