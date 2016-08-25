run(lambda do |env|
  [200, {}, [ENV['PRAX_ENV_VAR']]]
end)
