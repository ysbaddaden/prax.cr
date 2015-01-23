require "process"

lib C
  fun kill(pid : Int32, signal : Int32) : Int32
end

def Process.kill(pid, signal = Signal::TERM)
  if C.kill(pid, signal) == -1
    raise Errno.new("Error while killing pid #{pid}")
  end
end
