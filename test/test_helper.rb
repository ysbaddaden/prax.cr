require "net/http"
require "minitest/autorun"
require "minitest/pride"

begin
  bin = File.expand_path("../../bin/prax-binary", __FILE__)
  hosts = File.expand_path("../hosts", __FILE__)
  env = { "PRAX_ROOT" => ENV["PWD"] }
  pid = Process.spawn env, bin, "--port", "20557", "--hosts", hosts, "--verbose", out: "/dev/null", err: "/dev/null"

  Minitest.after_run do
    Process.kill(:TERM, pid)
    Process.wait(pid)
  end
end

module Minitest
  class Test
    self.make_my_diffs_pretty!
    self.parallelize_me!

    alias_method :run_without_timeout, :run

    def run
      capture_exceptions do
        Timeout.timeout(5) { run_without_timeout }
      end

      self
    end
  end
end
