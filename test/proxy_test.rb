require_relative "test_helper"

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

  def test_supports_xip_io
    assert_equal "example", Net::HTTP.get(URI("http://example.127.0.0.1.xip.io:20557/"))
    assert_equal "example", Net::HTTP.get(URI("http://w1.example.127.0.0.1.xip.io:20557/"))

    assert_equal "app1.example", Net::HTTP.get(URI("http://app1.example.127.0.0.1.xip.io:20557/"))
    assert_equal "app2.example", Net::HTTP.get(URI("http://w3.app2.example.127.0.0.1.xip.io:20557/"))
  end

  def test_returns_multiple_set_cookie_headers
    response = Net::HTTP.get_response(URI("http://cookies.dev:20557/"))
    assert_equal ["first=123, second=456"], response.get_fields("Set-Cookie")
  end

  def test_supports_bundler_with_special_gems
    assert_equal "1.0", Net::HTTP.get(URI("http://bundler.dev:20557/"))
  end
end
