module Prax
  def self.applications
    @@applications ||= [] of Application
  end

  class Application
    def self.find(name)
      if app = Prax.applications.find { |a| a.name == name.to_s }
        app.touch
        return app
      end

      if Path.exists?(name)
        app = new(name)
        Prax.applications << app
        app
      end
    end

    def self.search(host)
      search(host) do |name|
        if app = find(name)
          return app
        end
      end

      name = host.split('.').tap(&.pop).join('.')
      raise ApplicationNotFound.new(name, host)
    end

    private def self.search(host)
      if m = NIP_IO.match(host)
        host = m[1] + ".test"
      end
      names = host.split('.').tap(&.pop)

      until names.empty?
        yield names.join('.')
        names.shift
      end

      yield :default
    end
  end
end
