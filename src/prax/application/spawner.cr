module Prax
  class Spawner
    getter :app, :path

    def initialize(@app)
      @path = @app.path
    end

    def spawn_rack_application
      cmd = [] of String
      cmd += ["bundle", "exec"] if path.gemfile?
      cmd += ["rackup", "--host", "localhost", "--port", app.port.to_s]

      File.open(path.log_path, "w") do |log|
        @pid = Process.spawn(cmd, output: log, error: log, chdir: path.to_s)
      end

      wait!
    end

    def spawn_shell_application
      cmd = ["sh", path.to_s]
      env = { PORT: app.port }

      File.open(path.log_path, "w") do |log|
        @pid = Process.spawn(cmd, env: env, output: log, error: log)
      end

      wait!
    end

    def kill
      if pid = @pid
        Process.kill(pid, Signal::TERM)
      end

      reap!
    end

    private def wait!
      timer = Time.now

      loop do
        sleep 0.1

        break unless alive?
        return if connectable?

        if (Time.now - timer).total_seconds > 30
          Prax.logger.error "Timeout Starting Application: #{app.name}"
          kill
          break
        end
      end

      Prax.logger.error "Error Starting Application: #{app.name}"
      reap!
      raise ErrorStartingApplication.new
    end

    private def connectable?
      sock = app.connect
      true
    rescue ex : Errno
      unless ex.errno == Errno::ECONNREFUSED
        reap!
        raise ex
      end
      false
    ensure
      sock.close if sock
    end

    # TODO: SIGCHLD trap that will wait all child PIDs with WNOHANG
    private def reap!
      Thread.new do
        if pid = @pid
          Process.waitpid(pid)
        end
      end
    end

    private def alive?
      return false unless pid = @pid
      Process.waitpid(pid, LibC::WNOHANG)
      true
    rescue
      @pid = nil
      false
    end
  end
end
