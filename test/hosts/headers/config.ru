require "json"

run(lambda do |env|
  http_headers = env
    .map { |name, value| [name, value] if name =~ /^HTTP_/ }
    .compact
  [200, { "Content-Type" => "application/json" }, [Hash[http_headers].to_json, "\n"]]
end)
