# frozen_string_literal: true

require 'dotenv/load'

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

time_service = Kivsee::Trigger::Services::TimeService.new
mqtt_service = Kivsee::Trigger::Services::MqttService.new(ENV.fetch('MQTT_BROKER_IP'))
led_sequence_service = Kivsee::Trigger::Services::LedSequenceService.new(ENV.fetch('LED_SEQ_SERVICE_IP'),
                                                                         ENV.fetch('LED_SEQ_SERVICE_PORT', 8082))
player_service = Kivsee::Trigger::Services::PlayerService.new(ENV.fetch('PLAYER_IP'), ENV.fetch('PLAYER_PORT', 8080))

trigger_state = Kivsee::Trigger::TriggerState.new(mqtt_service, time_service)
player_events = Kivsee::Trigger::PlayerEvents.new(trigger_state, ENV.fetch('PLAYER_IP'),
                                                  ENV.fetch('PLAYER_WS_PORT', 9002))

post '/song/:song_name/play' do
  trigger_name = params['song_name']
  sequence_guid = led_sequence_service.latest_led_sequence_guid(trigger_name)
  data = player_service.play_song(trigger_name)
  trigger_state.set_song(trigger_name, sequence_guid, data['uuid'], data['play_seq_id'])
  data['operation_desc']
end
