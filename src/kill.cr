lib LibC
  WNOHANG    = 0x00000001
  WUNTRACED  = 0x00000002
  WSTOPPED   = WUNTRACED
  WEXITED    = 0x00000004
  WCONTINUED = 0x00000008
  WNOWAIT    = 0x01000008
end

module Process
  def self.waitpid(pid, options = 0)
    if LibC.waitpid(pid, out exit_code, options) == -1
      raise Errno.new("Error during waitpid")
    end
    exit_code >> 8
  end
end
