require "./path"
require "./errors"
require "./application/finders"
require "../kill"
require "../spawn"

lib LibC
  WNOHANG    = 0x00000001
  WUNTRACED  = 0x00000002
  WSTOPPED   = WUNTRACED
  WEXITED    = 0x00000004
  WCONTINUED = 0x00000008
  WNOWAIT    = 0x01000008

  P_ALL  = 0
  P_PID  = 1
  P_PGID = 2

  fun waitid(idtype : Int32, pid : Int32, status : Int32*, options : Int32) : Int32
end

#def Process.waitpid(pid, options = 0)
#  if LibC.waitpid(pid, out exit_code, 0) == -1
#    raise Errno.new("Error during waitpid")
#  end
#  exit_code >> 8
#end

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

    # FIXME: mutex for tread safety
    def start
      if started?
        return
      end

      if path.rack?
        puts "Starting Rack Application: #{name} port #{port}"
        return spawn_rack_application
      end

      if path.shell?
        puts "Starting Shell Application: #{name} port #{port}"
        return spawn_shell_application
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
        Dir.chdir(path.to_s) do
          @pid = Process.spawn(cmd, output: log, error: log)
        end
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
          puts "Timeout Starting Application: #{name}"
          stop
          break
        end
      end

      puts "Error Starting Application: #{name}"
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
      if LibC.waitpid(pid, out exit_code, LibC::WNOHANG) == -1
        @pid = nil
      else
        true
      end
    end
  end
end
