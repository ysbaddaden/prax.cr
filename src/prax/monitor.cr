module Prax
  module Monitor
    DELAY = 5.minutes.total_seconds
    TTL = 10.minutes

    def self.clear_stalled_applications
      Prax.applications.each do |app|
        if app.last_accessed_at + TTL < Time.now
          Prax.applications.delete(app)
          app.stop
        end
      end
    end

    def self.start
      Thread.new do
        loop do
          ::sleep DELAY
          clear_stalled_applications
        end
      end
    end
  end
end
