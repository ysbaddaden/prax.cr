require_relative "test_helper"

class KeepaliveTest < Minitest::Test
  def test_handles_multiple_request_on_a_single_connection
    TCPSocket.open("localhost", 20557) do |socket|
      socket.write "GET / HTTP/1.1\r\nHost: app1.example.dev\r\nContent-Length: 0\r\n\r\n"
      socket.write "GET / HTTP/1.1\r\nHost: app2.example.dev\r\nContent-Length: 0\r\n\r\n"
      socket.write "GET / HTTP/1.1\r\nHost: example.dev\r\nContent-Length: 0\r\n\r\n"

      assert_equal "HTTP/1.1 200 OK\r\n", socket.gets
      assert_match "app1.example", read(socket)

      assert_equal "HTTP/1.1 200 OK\r\n", socket.gets
      assert_match "app2.example", read(socket)

      assert_equal "HTTP/1.1 200 OK\r\n", socket.gets
      assert_match "example", read(socket)
    end
  end

  def test_no_keepalive_for_connection_close
    TCPSocket.open("localhost", 20557) do |socket|
      socket.write "GET / HTTP/1.1\r\nHost: example.dev\r\nContent-Length: 0\r\nConnection: close\r\n\r\n"
      socket.read # won't block for 15 seconds
    end
  end

  def read(socket)
    response = ""

    loop do
      response += line = socket.gets

      if line == "0\r\n"
        socket.gets # "\r\n"
        return response
      end
    end
  end
end
