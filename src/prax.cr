require "signal"
require "./env"
require "./prax/server"
require "./prax/monitor"

module Prax
  ROOT = ENV.fetch("PRAX_ROOT", File.join(ENV["HOME"], ".prax"))
  HTTP_PORT = ENV.fetch("PRAX_HTTP_PORT", 20559).to_i

  class Error < Exception; end
  class BadRequest < Error; end

  def self.start
    Monitor.start
    server.run(HTTP_PORT)
  end

  def self.stop
    server.stop
  end

  def self.server
    @@server ||= Server.new
  end
end

module Signal
  trap(INT)  { Prax.stop; exit }
  trap(TERM) { Prax.stop; exit }
  trap(QUIT) { Prax.stop; exit }
end

Prax.start
