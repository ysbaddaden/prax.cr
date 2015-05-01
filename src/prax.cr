require "signal"
require "logger"
require "option_parser"
require "./env"
require "./prax/config"
require "./prax/errors"
require "./prax/server"
require "./prax/monitor"

module Prax
  VERSION = {{ `cat VERSION`.stringify.chomp }}
  BUILD_DATE = {{ `date --utc +'%Y-%m-%d'`.stringify.chomp }}
  #BUILD_REVISION = {{ `git rev-parse --short HEAD` }}

  class Error < Exception; end
  class BadRequest < Error; end

  macro def self.version_string : String
    "Prax #{VERSION} (#{BUILD_DATE})"
  end

  def self.start
    Monitor.start
    server.run(http_port, https_port)
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
      logger.level = logger_level
      logger
    end
  end
end

module Signal
  trap(INT)  { Prax.stop; exit }
  trap(TERM) { Prax.stop; exit }
  trap(QUIT) { Prax.stop; exit }
  trap(PIPE, IGNORE)

  # FIXME: setting SIGCHLD to SIG_IGN doesn't work as expected (SIGCHLD isn't signaled)
  trap(CHLD, IGNORE)
end

OptionParser.parse! do |opts|
  opts.banner = "prax"

  opts.on("-d", "--daemon", "Daemonize the server into the background") do
    Prax.daemonize = true
  end

  opts.on("-p PORT", "--port PORT", "TCP port to bind to") do |port|
    Prax.http_port = port.to_i
  end

  opts.on("-h PATH", "--hosts PATH", "Path where hosts are linked to") do |path|
    Prax.hosts_path = path
  end

  opts.on("-l PATH", "--logs PATH", "Path where to write application logs to") do |path|
    Prax.logs_path = path
  end

  opts.on("-V", "--verbose", "Print debug statements to output") do
    Prax.logger_level = Logger::DEBUG
  end

  opts.on("-q", "--quiet", "Quiet down output") do
    Prax.logger_level = Logger::WARN
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

if Prax.daemonize
  exit if fork
  LibC.setsid
  exit if fork
  Dir.chdir "/"
  File.open("/dev/null").reopen(STDIN)
  File.open("/dev/null").reopen(STDOUT)
  File.open("/dev/null").reopen(STDERR)
  Prax.start
end

Prax.start
