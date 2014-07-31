require 'sinatra'

get "/endpoint" do
  if params["hub.mode"] == "challenge"
    status 200
    body params["hub.challenge"].to_s
  else
    status 400
    body ""
  end
end

post "/endpoint" do
  status 200
  body request.body
end
