require_relative 'test_helper'

class FailuresTest < Minitest::Test
  def test_rackup_config
    File.unlink log_path(:invalid) rescue nil
    html = Net::HTTP.get(URI('http://invalid.dev:20557/'))

    assert_match "Error starting application", html
    assert_match "crash on application boot", html
    assert_match "crash on application boot", log(:invalid)
  end

  def test_rackup_config_runs_nothing
    File.unlink log_path('wont-run') rescue nil
    html = Net::HTTP.get(URI('http://wont-run.dev:20557/'))

    assert_match "Error starting application", html
    assert_match "missing run or map statement", html
    assert_match "missing run or map statement", log('wont-run')
  end

  def test_host_header_is_missing_but_found_in_uri
    TCPSocket.open("localhost", 20557) do |socket|
      socket.write("GET http://example.dev:20557/ HTTP/1.1\r\n\r\n")
      assert_equal "HTTP/1.1 200 OK\r\n", socket.gets
    end
  end

  def test_host_cant_be_determined
    TCPSocket.open("localhost", 20557) do |socket|
      socket.write("GET /test HTTP/1.0\r\n\r\n")
      assert_equal "HTTP/1.0 400 BAD REQUEST\r\n", socket.gets
      assert_match "Bad Request: missing host header", socket.read
    end
  end

  def log(app_name)
    File.read log_path(app_name)
  end

  def log_path(app_name)
    File.expand_path("../hosts/_logs/#{app_name}.log", __FILE__)
  end
end
