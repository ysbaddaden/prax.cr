module Prax
  module Monitor
    DELAY = 5.minutes.total_seconds
    TTL = 9.minutes

    def self.clear_stalled_applications
      Prax.logger.debug "clearing stalled applications"

      # iterates the application array in reverse order, so deleting an
      # application from the array won't skip an entry:
      Prax.applications.reverse_each do |app|
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
      Prax.logger.error "monitor crashed: #{ex}"
    end
  end
end
