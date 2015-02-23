require "signal"
require "logger"
require "option_parser"
require "./env"
require "./prax/errors"
require "./prax/server"
require "./prax/monitor"

module Prax
  VERSION = {{ `cat VERSION`.stringify.chomp }}
  BUILD_DATE = {{ `date --utc +'%Y-%m-%d'`.stringify.chomp }}
  #BUILD_REVISION = {{ `git rev-parse --short HEAD` }}

  HOSTS = ENV.fetch("PRAX_HOSTS", File.join(ENV["HOME"], ".prax"))
  LOGS = ENV.fetch("PRAX_LOGS", File.join(HOSTS, "_logs"))
  HTTP_PORT = ENV.fetch("PRAX_HTTP_PORT", 20559).to_i

  class Error < Exception; end
  class BadRequest < Error; end

  macro def self.version_string : String
    "Prax #{VERSION} (#{BUILD_DATE})"
  end

  def self.start
    Monitor.start
    server.run(HTTP_PORT)
  end

  def self.stop
    server.stop
    applications.each(&.stop)
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

OptionParser.parse! do |opts|
  opts.banner = "prax"

  opts.on("-V", "--verbose", "Print debug statements to output") do
    Prax.logger.level = Logger::DEBUG
  end

  opts.on("-q", "--quiet", "Quiet down output") do
    Prax.logger.level = Logger::WARN
  end

  opts.on("-v", "--version", "Show the version number") do
    puts Prax.version_string
    exit
  end

  opts.on("-h", "--help", "Show help") do
    puts opts
    exit
  end
end

Prax.start
