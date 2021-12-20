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
          if @unconsumed_song_is_playing
            publish_trigger @unconsumed_start_time_ms_since_epoch
          else
            publish_no_trigger
          end
        end

        if (!@unconsumed_play_seq_id.nil? && player_play_seq_id >= @unconsumed_play_seq_id) || (player_uuid != @unconsumed_uuid)
          clear_future_report
        end
      end

      def player_offset_update(player_uuid, player_play_seq_id, song_is_playing, start_time_ms_since_epoch)
        case @player_uuid
        when nil
          store_future_report player_uuid, player_play_seq_id, song_is_playing, start_time_ms_since_epoch
        when player_uuid
          if player_play_seq_id < @player_play_seq_id
            nil
          elsif player_play_seq_id == @player_play_seq_id
            if song_is_playing
              publish_trigger start_time_ms_since_epoch
            else
              publish_no_trigger
            end
          elsif @unconsumed_play_seq_id.nil? || (player_play_seq_id >= @unconsumed_play_seq_id)
            store_future_report player_uuid, player_play_seq_id, song_is_playing, start_time_ms_since_epoch
          end
        end
      end

      def store_future_report(player_uuid, player_play_seq_id, song_is_playing, start_time_ms_since_epoch)
        @unconsumed_uuid = player_uuid
        @unconsumed_play_seq_id = player_play_seq_id
        @unconsumed_start_time_ms_since_epoch = start_time_ms_since_epoch
        @unconsumed_song_is_playing = song_is_playing
      end

      def clear_future_report()
        @unconsumed_uuid = nil
        @unconsumed_play_seq_id = nil
        @unconsumed_start_time_ms_since_epoch = nil
        @unconsumed_song_is_playing = nil
      end

      def publish_no_trigger()
        @mqtt_service.publish_no_trigger
      end

      def publish_trigger(start_time_ms_since_epoch)
        return if !@trigger_name 
        @mqtt_service.publish_trigger @sequence_guid, @trigger_name, start_time_ms_since_epoch
      end
    end
  end
end
