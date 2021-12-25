# frozen_string_literal: true

require 'dotenv/load'
require 'json'

require_relative './services/time'
require_relative './services/mqtt'
require_relative './services/led_sequence'
require_relative './services/player'

require_relative './trigger_state'
require_relative './player_events'

# this should be required after services, so that celluloid is required (via the service) first
# and install it's at_exit hook before sinatra
require 'sinatra'
require 'sinatra/reloader' if development?

require_relative './instrument'

time_service = Kivsee::Trigger::Services::TimeService.new
mqtt_service = Kivsee::Trigger::Services::MqttService.new(ENV.fetch('BROKER_URL'))
led_sequence_service = Kivsee::Trigger::Services::LedSequenceService.new(ENV.fetch('LED_SEQ_SERVICE_IP'),
                                                                         ENV.fetch('LED_SEQ_SERVICE_PORT', 8082))
player_service = Kivsee::Trigger::Services::PlayerService.new(ENV.fetch('PLAYER_IP'), ENV.fetch('PLAYER_PORT', 8080))

trigger_state = Kivsee::Trigger::TriggerState.new(mqtt_service)
player_events = Kivsee::Trigger::PlayerEvents.new(trigger_state, ENV.fetch('PLAYER_IP'),
                                                  ENV.fetch('PLAYER_WS_PORT', 9002))

player_events.start

before do
  body_content = request.body.read.to_s
  @req_data = body_content.empty? ? {} : JSON.parse(body_content)
end

post '/song/:song_name/play' do
  trigger_name = params['song_name']
  sequence_guid = @req_data['sequence_guid']
  unless sequence_guid
    sequence_guid, sequence_msg = led_sequence_service.latest_led_sequence_guid(trigger_name)
    return 404, sequence_msg unless sequence_guid
  end
  start_offset_ms = @req_data['start_offset_ms'] || 0
  player_success, data = player_service.play_song(trigger_name, start_offset_ms)
  return 404, data['operation_desc'] unless player_success

  trigger_state.set_song(trigger_name, sequence_guid, data['uuid'], data['play_seq_id'])
  data['operation_desc']
end

post '/trigger/:trigger_name' do
  player_service.stop
  trigger_name = params['trigger_name']
  sequence_guid = @req_data['sequence_guid']
  unless sequence_guid
    sequence_guid, sequence_msg = led_sequence_service.latest_led_sequence_guid(trigger_name)
    return 404, sequence_msg unless sequence_guid
  end
  start_time_millis_since_epoch = @req_data['start_time_millis_since_epoch'] || time_service.current_ms_since_epoch
  trigger_state.set_trigger(trigger_name, sequence_guid, start_time_millis_since_epoch)
  "started trigger #{trigger_name}"
end

post '/stop' do
  player_success, player_res = player_service.stop
  return 400, player_res['operation_desc'] unless player_success

  trigger_state.stop
end
