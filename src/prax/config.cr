module Prax
  def self.daemonize
    @@daemonize
  end

  def self.daemonize=(value : Bool)
    @@daemonize = value
  end

  def self.logger_level
    @@logger_level ||= Log::Severity::Info
  end

  def self.logger_level=(level : Log::Severity)
    @@logger_level = level
  end

  def self.hosts_path
    @@hosts_path ||= ENV.fetch("PRAX_HOSTS", File.join(ENV["HOME"], ".prax")).tap do |path|
      Dir.mkdir(path) unless Dir.exists?(path)
    end
  end

  def self.hosts_path=(path : String)
    @@hosts_path = path
  end

  def self.logs_path
    @@logs_path ||= ENV.fetch("PRAX_LOGS", File.join(hosts_path, "_logs"))
  end

  def self.logs_path=(path : String)
    @@logs_path = path
  end

  def self.http_port
    @@http_port ||= ENV.fetch("PRAX_HTTP_PORT", 20559).to_i
  end

  def self.http_port=(port : Int32)
    @@http_port = port
  end

  def self.https_port
    @@https_port ||= ENV.fetch("PRAX_HTTPS_PORT", 20558).to_i
  end

  def self.https_port=(port : Int32)
    @@https_port = port
  end

  def self.timeout
    @@timeout ||= ENV.fetch("PRAX_TIMEOUT", 30).to_i
  end

  def self.timeout=(wait : Int32)
    @@timeout = wait
  end

  def self.root_path
    ENV["PRAX_ROOT"]
  end
end
