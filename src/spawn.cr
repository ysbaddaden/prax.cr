require "process"

def Process.spawn(command, env = nil, in = nil : IO | String, out = nil : IO | Bool, err = nil : IO | Bool)
  argv = command.map(&.cstr)
  argv << Pointer(UInt8).null

  pid = fork do
    if env
      env.each { |key, value| ENV[key.to_s] = value.to_s }
    end

    if in
      in.reopen(STDIN)
    end

    if out == false
      null = File.new("/dev/null", "r+")
      null.reopen(STDOUT)
    elsif out
      out.reopen(STDOUT)
    end

    if err == false
      null = File.new("/dev/null", "r+")
      null.reopen(STDERR)
    elsif err
      err.reopen(STDERR)
    end

    C.execvp(argv.first, argv.buffer)
    C.exit 127
  end

  if pid == -1
    raise Errno.new("Couldn't fork to spawn #{command}")
  end

  pid
end
