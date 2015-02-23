run(lambda do |env|
  body = [ENV["VAR1"], ENV["VAR2"], ENV["VAR3"], ENV["VAR4"]]
    .map(&:to_s).join(" ")

  [200, {}, [body]]
end)
