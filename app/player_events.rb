# frozen_string_literal: true

require 'eventmachine'
require 'faye/websocket'

module Kivsee
  module Trigger
    # register to receive events from player on what is being played
    class PlayerEvents
      def initialize(trigger_state, player_host, player_ws_port)
        @trigger_state = trigger_state
        @player_host = player_host
        @player_ws_port = player_ws_port

        @started = false
      end

      def start
        return if @started

        @started = true
        Thread.new do
          em_start
        end
      end

      def em_start # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        EM.run do
          ws = Faye::WebSocket::Client.new("ws://#{@player_host}:#{@player_ws_port}/")

          ws.on :open do |_event|
            p [:open]
          end

          ws.on :message do |event|
            data = JSON.parse event.data
            p data
            @trigger_state.async.player_offset_update(data['uuid'], data['play_seq_id'], data['song_is_playing'],
                                                      data['start_time_millis_since_epoch'])
          end

          ws.on :close do |event|
            p [:close, event.code, event.reason]
            ws = nil
          end
        end
      end
    end
  end
end
