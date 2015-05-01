module Prax
  module Monitor
    DELAY = 5.seconds.total_seconds
    TTL = 4.seconds

    def self.clear_stalled_applications
      Prax.logger.debug "clearing stalled applications"

      Prax.applications.each do |app|
        if app.last_accessed_at + TTL < Time.now
          Prax.applications.delete(app)
          app.stop
        end
      end
    end

    def self.start
      spawn do
        loop { monitor }
      end
    end

    private def self.monitor
      ::sleep DELAY
      clear_stalled_applications
    rescue ex
      Prax.logger.debug "monitor crashed: #{ex}"
    end
  end
end
