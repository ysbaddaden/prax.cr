lib LibC
  fun kill(pid : Int32, signal : Int32) : Int32

  WNOHANG    = 0x00000001
  WUNTRACED  = 0x00000002
  WSTOPPED   = WUNTRACED
  WEXITED    = 0x00000004
  WCONTINUED = 0x00000008
  WNOWAIT    = 0x01000008
end

module Process
  def self.kill(pid, signal = Signal::TERM)
    if LibC.kill(pid, signal) == -1
      raise Errno.new("Error while killing pid #{pid}")
    end
  end

  def self.waitpid(pid, options = 0)
    if LibC.waitpid(pid, out exit_code, options) == -1
      raise Errno.new("Error during waitpid")
    end
    exit_code >> 8
  end
end
