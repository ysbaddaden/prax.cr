require "thread"
require "../../kill"

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
      env = load_env

      File.open(path.log_path, "w") do |log|
        @pid = Process.spawn(cmd, env: env, output: log, error: log, chdir: path.to_s)
      end

      wait!
    end

    def spawn_shell_application
      cmd = ["sh", path.to_s]
      env = load_env
      env["PORT"] = app.port.to_s

      File.open(path.log_path, "w") do |log|
        @pid = Process.spawn(cmd, env: env, output: log, error: log)
      end

      wait!
    end

    def kill
      if pid = @pid
        Process.kill(Signal::TERM, pid)
      end

      reap!
    end

    def load_env
      env = {} of String => String
      return env unless @app.path.env?

      Prax.logger.debug "loading #{app.name}/.env file"

      lines = File.read_lines(@app.path.env_path)
        .map { |line| line.gsub(/#.+/, "").strip }
        .reject { |line| line.empty? || !line.index('=') }

      lines.each do |line|
        kv = line.split('=', 2)
        env[kv[0]] = kv.size == 2 ? kv[1]: ""
      end

      env
    end

    private def wait!
      timer = Time.now

      loop do
        sleep 0.1

        break unless alive?
        return if connectable?

        if (Time.now - timer).total_seconds > 30
          Prax.logger.error "timeout starting application: #{app.name}"
          kill
          break
        end
      end

      Prax.logger.error "error starting application: #{app.name}"
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

    # FIXME: setting SIGCHLD to SIG_IGN doesn't work as expected (SIGCHLD isn't signaled)
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
