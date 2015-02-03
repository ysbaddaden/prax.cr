require "process"

module IO
  def self.select(read_array, write_array = nil, error_array = nil, timeout = nil)
    nfds = 0

    rfds = Process::FdSet.new
    read_array.each { |io| rfds.set(io); nfds = Math.max(nfds, io.fd) } if read_array

    wfds = Process::FdSet.new
    write_array.each { |io| wfds.set(io); nfds = Math.max(nfds, io.fd) } if write_array

    efds = Process::FdSet.new
    error_array.each { |io| efds.set(io); nfds = Math.max(nfds, io.fd) } if error_array

    case LibC.select(nfds + 1, pointerof(rfds) as Void*, pointerof(wfds) as Void*, pointerof(efds) as Void*, timeout)
    when 0
      # TODO: raise timeout
    when -1
      # TODO: raise error
    else
      yield rfds, wfds, efds
    end
  end
end
