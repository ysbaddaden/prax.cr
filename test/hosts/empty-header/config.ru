run(lambda do |env|
  [200, { "Access-Control-Expose-Headers" => "" }, ["an empty header is tolerated"]]
end)
