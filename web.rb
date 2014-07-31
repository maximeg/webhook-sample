require 'sinatra'

get "/" do
  body <<-HTML
    <h1>Webhook consumer sample</h1>
    <p><a href="/endpoint">/endpoint</a></p>
  HTML
end

get "/endpoint" do
  if params["hub.mode"] == "challenge"
    status 200
    body params["hub.challenge"].to_s
  else
    status 400
    body "Invalid challenge request"
  end
end

post "/endpoint" do
  status 200
  body request.body
end
