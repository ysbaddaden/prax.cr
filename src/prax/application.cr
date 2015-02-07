require "./path"
require "./errors"
require "./application/finders"
require "../kill"
require "../spawn"

module Prax
  XIP_IO = /\A(.+)\.(?:\d+\.){4}xip\.io\Z/

  # TODO: extract spawn part to an Application::Spawner class/module
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

    # FIXME: protect with a mutex for tread safety
    def start
      if started?
        return
      end

      if path.rack?
        Prax.logger.info "Starting Rack Application: #{name} (port #{port})"
        return spawn_rack_application
      end

      if path.shell?
        Prax.logger.info "Starting Shell Application: #{name} (port #{port})"
        return spawn_shell_application
      end
    end

    def stop
      if pid = @pid
        Prax.logger.info "Killing Application: #{name}"
        Process.kill(pid, Signal::TERM)
        reap(pid)
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

    private def connect
      #if path.rack?
      #  UNIXSocket.new(path.socket_path)
      #else
        TCPSocket.new("127.0.0.1", port)
      #end
    end

    private def find_available_port
      server = TCPServer.new(0)
      server.addr.ip_port
    ensure
      server.close if server
    end

    # TODO: push chdir param to Process.spawn
    private def spawn_rack_application
      cmd = [] of String
      cmd += ["bundle", "exec"] if path.gemfile?
      cmd += ["rackup", "--host", "localhost", "--port", port.to_s]

      File.open(path.log_path, "w") do |log|
        @pid = Process.spawn(cmd, output: log, error: log, chdir: path.to_s)
      end

      wait!
    end

    private def spawn_shell_application
      cmd = ["sh", path.to_s]
      env = { PORT: port }

      File.open(path.log_path, "w") do |log|
        @pid = Process.spawn(cmd, env: env, output: log, error: log)
      end

      wait!
    end

    private def wait!
      timer = Time.now
      pid = @pid.not_nil!

      loop do
        sleep 0.1

        break unless alive?(pid)
        return if connectable?(pid)

        if (Time.now - timer).total_seconds > 30
          Prax.logger.error "Timeout Starting Application: #{name}"
          stop
          break
        end
      end

      Prax.logger.error "Error Starting Application: #{name}"
      reap(pid)
      raise ErrorStartingApplication.new
    end

    private def connectable?(pid)
      sock = connect
      true
    rescue ex : Errno
      unless ex.errno == Errno::ECONNREFUSED
        reap(pid)
        raise ex
      end
      false
    ensure
      sock.close if sock
    end

    # TODO: SIGCHLD trap that will wait all child PIDs with WNOHANG
    private def reap(pid)
      Thread.new { Process.waitpid(pid) } if pid
    end

    private def alive?(pid)
      Process.waitpid(pid, LibC::WNOHANG)
      true
    rescue
      @pid = nil
      false
    end
  end
end
