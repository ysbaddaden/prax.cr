module Prax
  class Spawner
    getter app : Application
    getter channel
    getter! exception : Exception
    getter started_at : Time?

    def initialize(@app)
      @channel = Channel(Tuple(Channel(String), String)).new(10)

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
        Prax.logger.info { "#{action} rack application: #{app.name} (port #{app.port})" }
        spawn_rack_application
      elsif path.shell?
        Prax.logger.info { "#{action} shell application: #{app.name} (port #{app.port})" }
        spawn_shell_application
      else
      end

      @started_at = Time.utc
    end

    private def stop(restart = false)
      return if stopped?

      Prax.logger.info { "killing application: #{app.name}" } unless restart
      kill

      @started_at = nil
    end

    private def spawn_rack_application
      cmd = [] of String
      cmd << File.join(ENV["PRAX_ROOT"],"bin", "prax-rc") if path.praxrc?
      cmd += ["bundle", "exec"] if path.gemfile?
      cmd += ["rackup", "--host", "127.0.0.1", "--port", app.port.to_s]

      File.open(path.log_path, "w") do |log|
        @process = Process.new(cmd.first, cmd[1 .. -1], output: log, error: log, chdir: path.to_s)
      end

      wait!
    end

    private def spawn_shell_application
      cmd = ["sh", path.to_s]
      env = {} of String => String
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

    private def wait!
      timer = Time.monotonic

      loop do
        sleep 0.1

        break unless alive?
        return if connectable?

        if (Time.monotonic - timer).total_seconds > Prax.timeout
          Prax.logger.error { "timeout starting application: #{app.name}" }
          kill
          break
        end
      end

      Prax.logger.error { "error starting application: #{app.name}" }
      raise ErrorStartingApplication.new
    end

    private def connectable?
      app.connect { true }
    rescue ex : Socket::ConnectError
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
