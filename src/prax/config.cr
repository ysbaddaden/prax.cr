module Prax
  def self.daemonize
    @@daemonize
  end

  def self.daemonize=(value)
    @@daemonize = value
  end

  def self.logger_level
    @@logger_level ||= ENV.has_key?("PRAX_DEBUG") ? Logger::DEBUG : Logger::INFO
  end

  def self.logger_level=(level)
    @@logger_level = level
  end

  def self.hosts_path
    @@hosts_path ||= ENV.fetch("PRAX_HOSTS", File.join(ENV["HOME"], ".prax"))
  end

  def self.hosts_path=(level)
    @@hosts_path = level
  end

  def self.logs_path
    @@logs_path ||= ENV.fetch("PRAX_LOGS", File.join(hosts_path, "_logs"))
  end

  def self.logs_path=(level)
    @@logs_path = level
  end

  def self.http_port
    @@http_port ||= ENV.fetch("PRAX_HTTP_PORT", 20559).to_i
  end

  def self.http_port=(level)
    @@http_port = level
  end
end
