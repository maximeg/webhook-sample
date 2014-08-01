$stdout.sync = true

require 'sinatra'
require 'json'

get "/" do
  body <<-HTML
    <h1>Webhook consumer sample</h1>
    <p>Use a name as a namespace</p>
    <p><a href="/my-name/endpoint">/:name/endpoint</a></p>
  HTML
end

get "/:name/endpoint" do
  puts "[WEBHOOK #{params[:name]}] Params received: #{params.inspect}"
  if params["hub.mode"] == "subscribe" && params["hub.challenge"] && params["hub.verify_token"]
    status 200
    body params["hub.challenge"].to_s
  else
    status 400
    body "Invalid challenge request"
  end
end

post "/:name/endpoint" do
  puts "[WEBHOOK #{params[:name]}] Body received: #{request.body.string}"
  payload = JSON.load(request.body.string)
  if events = payload["events"]
    events.all? do |event|
      if event["type"]
        puts "[WEBHOOK #{params[:name]}] Event received: #{event["type"]}: #{event.inspect}"
      else
        puts "[WEBHOOK #{params[:name]}] Invalid Event received: #{event.inspect}"
        status 400
        body "invalid event"
      end
    end

    status 200
  else
    puts "[WEBHOOK #{params[:name]}] No event received"
    status 400
    body "no events"
  end
end
