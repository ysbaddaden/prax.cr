require_relative "test_helper"

class PublicFileTest < Minitest::Test
  def test_serves_files_in_public_folder
    assert_equal "my file contents\n", Net::HTTP.get(URI("http://example.test:20557/file.txt"))
    assert_equal "my file contents\n", Net::HTTP.get(URI("http://example.127.0.0.1.xip.io:20557/file.txt"))
  end

  def test_serves_files_for_non_rack_application
    assert_equal "/index.html\n", Net::HTTP.get(URI("http://public.test:20557/index.html"))
    assert_equal "/folder/index.html\n", Net::HTTP.get(URI("http://public.test:20557/folder/index.html"))
  end

  def test_serves_index_html
    assert_equal "/index.html\n", Net::HTTP.get(URI("http://public.test:20557/"))
    assert_equal "/folder/index.html\n", Net::HTTP.get(URI("http://public.test:20557/folder"))
  end

  def test_sets_correct_content_type
    skip :MISSING_TEST
  end
end
