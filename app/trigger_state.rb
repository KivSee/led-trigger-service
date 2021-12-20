# frozen_string_literal: true

require 'celluloid/autostart'

module Kivsee
  module Trigger
    class TriggerState
      include Celluloid

      def initialize(mqtt_service, time_service)
        @mqtt_service = mqtt_service
        @time_service = time_service
      end

      # set the trigger without monitoring the song
      def set_trigger(trigger_name, sequence_guid)
        @trigger_name = trigger_name
        @sequence_guid = sequence_guid
        @player_uuid = nil
        @player_play_seq_id = nil

        publish_trigger @time_service.get_current_ms_since_epoch
      end

      # this function set the trigger on a song and monitor player updates on the start time
      def set_song(trigger_name, sequence_guid, player_uuid, player_play_seq_id)
        @trigger_name = trigger_name
        @sequence_guid = sequence_guid
        @player_uuid = player_uuid
        @player_play_seq_id = player_play_seq_id

        if (player_play_seq_id == @unconsumed_play_seq_id) && (player_uuid == @unconsumed_uuid)
          publish_trigger @unconsumed_start_time_ms_since_epoch
        end
      end

      def player_offset_update(player_uuid, player_play_seq_id, start_time_ms_since_epoch)
        case @player_uuid
        when nil
          store_future_report player_uuid, player_play_seq_id, start_time_ms_since_epoch
        when player_uuid
          if player_play_seq_id < @player_play_seq_id
            nil
          elsif player_play_seq_id == @player_play_seq_id
            publish_trigger start_time_ms_since_epoch
          elsif @unconsumed_play_seq_id.nil? || (player_play_seq_id >= @unconsumed_play_seq_id)
            store_future_report player_uuid, player_play_seq_id, start_time_ms_since_epoch
          end
        end
      end

      def store_future_report(player_uuid, player_play_seq_id, start_time_ms_since_epoch)
        @unconsumed_uuid = player_uuid
        @unconsumed_play_seq_id = player_play_seq_id
        @unconsumed_start_time_ms_since_epoch = start_time_ms_since_epoch
      end

      def publish_trigger(start_time_ms_since_epoch)
        @mqtt_service.publish_trigger @sequence_guid, @trigger_name, start_time_ms_since_epoch
      end
    end
  end
end
