$stdout.sync = true

require 'sinatra'
require 'json'

get "/" do
  body <<-HTML
    <h1>Webhook consumer sample</h1>
    <p><a href="/endpoint">/endpoint</a></p>
  HTML
end

get "/endpoint" do
  puts "WEBHOOK: Params received: #{params.inspect}"
  if params["hub.mode"] == "subscribe" && params["hub.challenge"] && params["hub.verify_token"]
    status 200
    body params["hub.challenge"].to_s
  else
    status 400
    body "Invalid challenge request"
  end
end

post "/endpoint" do
  puts "WEBHOOK: Body received: #{request.body.string}"
  payload = JSON.load(request.body.string)
  if events = payload["events"]
    events.all? do |event|
      if event["type"]
        puts "WEBHOOK: Event received: #{event["type"]}: #{event.inspect}"
      else
        puts "WEBHOOK: Invalid Event received: #{event.inspect}"
        status 400
        body "invalid event"
      end
    end

    status 200
  else
    puts "WEBHOOK: No event received"
    status 400
    body "no events"
  end
end
