$stdout.sync = true

require 'sinatra'
require 'json'

$logs = Hash.new { |h,k| h[k] = {} }

get "/" do
  erb :index
end

get "/:name/logs" do
  @name = params[:name]

  erb :logs
end

get "/:name/endpoint" do
  @name = params[:name]
  challenge_params = params.select do |key, value|
    !["captures", "splat", "name"].include?(key)
  end

  puts "[WEBHOOK #{@name}] Params received: #{challenge_params.inspect}"

  if params["hub.mode"] == "subscribe" && params["hub.challenge"] && params["hub.verify_token"]
    $logs[@name][Time.now] = "METHOD=GET, ParamsReceived=#{challenge_params.inspect}, STATUS=200"
    status 200
    body params["hub.challenge"].to_s
  else
    $logs[@name] << "METHOD=GET, ParamsReceived=#{challenge_params.inspect}, STATUS=400"
    status 400
    body "Invalid challenge request"
  end
end

post "/:name/endpoint" do
  @name = params[:name]
  puts "[WEBHOOK #{@name}] Body received: #{request.body.string}"
  payload = JSON.load(request.body.string) || {}
  if events = payload["events"]
    events.all? do |event|
      if event["type"]
        puts "[WEBHOOK #{@name}] Event received: #{event["type"]}: #{event.inspect}"
      else
        puts "[WEBHOOK #{@name}] Invalid Event received: #{event.inspect}"
        status 400
        body "invalid event"
      end
    end
    $logs[@name][Time.now] = "METHOD=POST, BodyReceived=#{payload.inspect}, STATUS=200"
    status 200
  else
    puts "[WEBHOOK #{@name}] No event received"
    $logs[@name][Time.now] = "METHOD=POST, BodyReceived=#{request.body.string}, STATUS=400"
    status 400
    body "no events"
  end
end
