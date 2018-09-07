require_relative "test_helper"

class PortForwardingTest < Minitest::Test
  def test_forwards_to_given_port
    ready = false
    response = "TCPServer: OK\n"

    t1 = Thread.new do
      server = TCPServer.new("::", 3123)
      ready = true
      loop do
        begin
          socket = server.accept_nonblock
          socket.write "HTTP/1.1 200 OK\r\nConnection: close\r\nContent-Length: #{response.size}\r\n\r\n#{response}"
          socket.flush
          break
        rescue Errno::EAGAIN
          Thread.pass
        end
      end
      server.close
    end

    until ready
      sleep(0.01)
      Thread.pass
    end

    assert_equal response, Net::HTTP.get(URI("http://forward.test:20557/"))
    t1.join
  end

  def test_forwards_to_given_host_and_port
    ready = false
    response = "TCPServer: OK\n"

    t1 = Thread.new do
      server = TCPServer.new("::1", 3124)
      ready = true
      loop do
        begin
          socket = server.accept_nonblock
          socket.write "HTTP/1.1 200 OK\r\nConnection: close\r\nContent-Length: #{response.size}\r\n\r\n#{response}"
          socket.flush
          break
        rescue Errno::EAGAIN
          Thread.pass
        end
      end
      server.close
    end

    until ready
      sleep(0.01)
      Thread.pass
    end

    assert_equal response, Net::HTTP.get(URI("http://forward-host.test:20557/"))
    t1.join
  end
end
