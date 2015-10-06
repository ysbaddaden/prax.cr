# Quick fix for https://github.com/manastech/crystal/issues/1700

module Event
  struct Base
    setter :dns_base
  end
end

class Scheduler
  @@eb.dns_base = @@eb.dns_base
end
