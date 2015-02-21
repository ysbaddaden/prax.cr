require "net/http"
require "minitest/autorun"
require "minitest/pride"

begin
  env = {
    "PRAX_HTTP_PORT" => "20557",
    "PRAX_HOSTS" => File.expand_path("../hosts", __FILE__),
  }
  bin = File.expand_path("../../bin/prax-binary", __FILE__)
  pid = Process.spawn env, bin #, out: "/dev/null", err: "/dev/null")

  Minitest.after_run do
    Process.kill(:TERM, pid)
    Process.wait(pid)
  end
end
