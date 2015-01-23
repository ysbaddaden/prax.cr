module ENV
  def self.fetch(key, default)
    if has_key?(key)
      self[key]
    else
      default
    end
  end
end
