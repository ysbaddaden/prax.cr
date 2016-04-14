require "thread"

module Prax
  class Spawner
    getter app : Application
    getter channel
    getter! exception : Exception
    getter started_at : Time?

    def initialize(@app)
      @channel = Channel::Buffered(Tuple(Channel::Unbuffered(String), String)).new

      ::spawn do
        loop do
          callee, command = @channel.receive
          execute(callee, command)
        end
      end
    end

    def path
      @app.path
    end

    def started?
      !!@started_at
    end

    def stopped?
      !started?
    end

    private def execute(callee, command)
      case command
      when "start"
        start
      when "stop"
        stop
      when "restart"
        stop(restart: true)
        start(restart: true)
      end
    rescue ErrorStartingApplication
      callee.send("error")
    rescue ex
      @exception = ex
      callee.send("exception")
    else
      callee.send("ok")
    end

    private def start(restart = false)
      return if started?
      action = restart ? "restarting" : "starting"

      if path.rack?
        Prax.logger.info "#{action} rack application: #{app.name} (port #{app.port})"
        spawn_rack_application
      elsif path.shell?
        Prax.logger.info "#{action} shell application: #{app.name} (port #{app.port})"
        spawn_shell_application
      else
      end

      @started_at = Time.utc_now
    end

    private def stop(restart = false)
      return if stopped?

      Prax.logger.info "killing application: #{app.name}" unless restart
      kill

      @started_at = nil
    end

    private def spawn_rack_application
      cmd = [] of String
      cmd += ["bundle", "exec"] if path.gemfile?
      cmd += ["rackup", "--host", "localhost", "--port", app.port.to_s]
      env = load_env

      File.open(path.log_path, "w") do |log|
        @process = Process.new(cmd.first, cmd[1 .. -1], env: env, output: log, error: log, chdir: path.to_s)
      end

      wait!
    end

    private def spawn_shell_application
      cmd = ["sh", path.to_s]
      env = load_env
      env["PORT"] = app.port.to_s

      File.open(path.log_path, "w") do |log|
        @process = Process.new(cmd.first, cmd[1 .. - 1], env: env, output: log, error: log, chdir: path.to_s)
      end

      wait!
    end

    private def kill
      if process = @process
        process.kill
      end
    end

    private def load_env
      env = {} of String => String
      return env unless @app.path.env?

      Prax.logger.debug { "loading #{app.name}/.env file" }

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
      raise ErrorStartingApplication.new
    end

    private def connectable?
      app.connect { true }
    rescue ex : Errno
      raise ex unless ex.errno == Errno::ECONNREFUSED
      false
    end

    private def alive?
      if process = @process
        exit_code = uninitialized LibC::Int
        LibC.waitpid(process.pid, pointerof(exit_code), LibC::WNOHANG) != -1
      else
        false
      end
    rescue
      @process = nil
      false
    end
  end
end
