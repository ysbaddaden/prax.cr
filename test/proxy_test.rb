require_relative "test_helper"
require "json"

class ProxyTest < Minitest::Test
  def test_proxies_to_rack_applications
    assert_equal "example", Net::HTTP.get(URI("http://example.dev:20557/"))
    assert_equal "example", Net::HTTP.get(URI("http://www.example.dev:20557/"))

    assert_equal "app1.example", Net::HTTP.get(URI("http://app1.example.dev:20557/"))
    assert_equal "app1.example", Net::HTTP.get(URI("http://www.app1.example.dev:20557/"))

    assert_equal "app2.example", Net::HTTP.get(URI("http://app2.example.dev:20557/"))
    assert_equal "app2.example", Net::HTTP.get(URI("http://w3.app2.example.dev:20557/"))
  end

  def test_proxies_to_shell_application
    skip "TODO: SHELL APPLICATION"
  end

  # This test may fail randomly.  You may have better success using OpenDNS.
  def test_supports_xip_io
    assert_equal "example", Net::HTTP.get(URI("http://example.127.0.0.1.xip.io:20557/"))
    assert_equal "example", Net::HTTP.get(URI("http://w1.example.127.0.0.1.xip.io:20557/"))

    assert_equal "app1.example", Net::HTTP.get(URI("http://app1.example.127.0.0.1.xip.io:20557/"))
    assert_equal "app2.example", Net::HTTP.get(URI("http://w3.app2.example.127.0.0.1.xip.io:20557/"))
  end

  def test_returns_multiple_set_cookie_headers
    response = Net::HTTP.get_response(URI("http://cookies.dev:20557/"))
    assert_equal ["first=123", "second=456"], response.get_fields("Set-Cookie")
  end

  def test_supports_bundler_with_special_gems
    assert_equal "1.0", Net::HTTP.get(URI("http://bundler.dev:20557/"))
  end

  def test_alters_request_headers_and_sets_proxy_headers
    response = Net::HTTP.get(URI("http://headers.dev:20557/"))
    headers = JSON.parse(response)

    assert_equal "headers.dev:20557", headers["HTTP_HOST"]
    assert_equal "close", headers["HTTP_CONNECTION"]

    assert_equal "headers.dev:20557", headers["HTTP_X_FORWARDED_HOST"]
    assert_equal "http", headers["HTTP_X_FORWARDED_PROTO"]
    assert_equal "::1", headers["HTTP_X_FORWARDED_FOR"]
    assert_equal "::1", headers["HTTP_X_FORWARDED_SERVER"]
  end

  def test_augments_proxy_headers
    Net::HTTP.start("headers.dev", 20557) do |http|
      response = http.get("/", {
        "X-Forwarded-For" => "192.168.1.53",
        "X-Forwarded-Server" => "10.0.3.1",
      })
      headers = JSON.parse(response.body)
      assert_equal "::1, 192.168.1.53", headers["HTTP_X_FORWARDED_FOR"]
      assert_equal "::1, 10.0.3.1", headers["HTTP_X_FORWARDED_SERVER"]
    end
  end

  def test_empty_header
    response = Net::HTTP.get_response(URI("http://empty-header.dev:20557/"))
    assert_equal "", response["Access-Control-Expose-Headers"]
    assert_equal "an empty header is tolerated", response.body
  end

  def test_lowercase_header
    TCPSocket.open("localhost", 20557) do |socket|
      socket.write("GET / HTTP/1.1\r\nhost: example.dev\r\n\r\n")
      assert_equal "HTTP/1.1 200 OK\r\n", socket.gets # a lowercase request header is tolerated
    end
  end
end
