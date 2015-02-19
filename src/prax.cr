require "signal"
require "logger"
require "./env"
require "./prax/errors"
require "./prax/server"
require "./prax/monitor"

module Prax
  HOSTS = ENV.fetch("PRAX_HOSTS", File.join(ENV["HOME"], ".prax"))
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

  def self.logger
    @@logger ||= Logger.new(STDOUT).tap do |logger|
      logger.progname = "prax"
      logger.level = Logger::DEBUG if ENV.has_key?("PRAX_DEBUG")
      logger
    end
  end
end

module Signal
  trap(INT)  { Prax.stop; exit }
  trap(TERM) { Prax.stop; exit }
  trap(QUIT) { Prax.stop; exit }
  trap(PIPE, IGNORE)
end

Prax.start
