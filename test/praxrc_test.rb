require_relative "test_helper"

class PraxrcTest < Minitest::Test
  def test_praxrc_loaded
    assert_equal "itworks", Net::HTTP.get(URI("http://praxrc.test:20557/"))
    assert_equal "itworks", Net::HTTP.get(URI("http://praxrc.127.0.0.1.xip.io:20557/"))
  end
end
