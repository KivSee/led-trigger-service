require 'dotenv/load'
require 'sinatra'
require 'faraday'
require 'json'
require 'mqtt'

seq_service_host = ENV['LED_SEQ_SERVICE_IP']
seq_service_port = ENV['LED_SEQ_SERVICE_PORT'] || 8082

seq_service_client = Faraday.new(:url => "http://#{seq_service_host}:#{seq_service_port}") do |faraday|
    faraday.request  :url_encoded             # form-encode POST params
    faraday.response :logger                  # log requests to STDOUT
    faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
end

mqtt_client = MQTT::Client.connect(ENV['MQTT_BROKER_IP'])

post '/song/:song_name/play' do
    trigger_name = params['song_name']
    response = seq_service_client.get "/triggers/#{trigger_name}/guid"
    data = JSON.parse response.body 
    sequence_guid = data['guid'] 
    trigger_msg = JSON.generate({
        :guid => sequence_guid,
        :trigger_name => trigger_name,
        :start_time_ms_since_epoch => 1234
    })
    mqtt_client.publish('trigger', trigger_msg, retain=true)
end

