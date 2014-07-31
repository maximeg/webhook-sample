$stdout.sync = true

require 'sinatra'

get "/" do
  body <<-HTML
    <h1>Webhook consumer sample</h1>
    <p><a href="/endpoint">/endpoint</a></p>
  HTML
end

get "/endpoint" do
  puts params.inspect
  if params["hub.mode"] == "challenge" && params["hub.challenge"] && params["hub.verify_token"]
    status 200
    body params["hub.challenge"].to_s
  else
    status 400
    body "Invalid challenge request"
  end
end

post "/endpoint" do
  puts request.body.try(:string)
  status 200
end
