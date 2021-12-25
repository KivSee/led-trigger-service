# frozen_string_literal: true

require 'celluloid/autostart'

module Kivsee
  module Trigger
    MODE_PLAYER = :mode_player
    MODE_TRIGGER = :mode_trigger

    # The last known state of the player, regardless of mode or if something is playing
    class PlayerState
      attr_accessor :uuid, :play_seq_id
    end

    # the trigger state we aim to get to
    class DesiredState
      attr_accessor :trigger_name, :sequence_guid, :mode

      def clear
        @trigger_name = nil
        @sequence_guid = nil
        @mode = nil
      end
    end

    # the last update on the status of the player regardless of desired state
    class CurrentPlayerState
      attr_accessor :uuid, :play_seq_id, :song_is_playing, :start_time_millis_since_epoch
    end

    # monitor the desired vs current state of the trigger and send updates when needed
    class TriggerState
      include Celluloid

      def initialize(mqtt_service)
        @mqtt_service = mqtt_service

        @player_state = PlayerState.new
        @desired_state = DesiredState.new
        @current_player_state = CurrentPlayerState.new
      end

      def stop
        current_trigger = @desired_state.trigger_name
        @desired_state.clear
        publish_no_trigger
        current_trigger
      end

      # set the trigger without monitoring the song
      def set_trigger(trigger_name, sequence_guid, start_time_millis_since_epoch)
        @desired_state.trigger_name = trigger_name
        @desired_state.sequence_guid = sequence_guid
        @desired_state.mode = MODE_TRIGGER
        publish_trigger start_time_millis_since_epoch
      end

      # this function set the trigger on a song and monitor player updates on the start time
      def set_song(trigger_name, sequence_guid, player_uuid, player_play_seq_id)
        @player_state.uuid = player_uuid
        @player_state.play_seq_id = player_play_seq_id

        @desired_state.trigger_name = trigger_name
        @desired_state.sequence_guid = sequence_guid
        @desired_state.mode = MODE_PLAYER

        update_song_status
      end

      def player_offset_update(player_uuid, player_play_seq_id, song_is_playing, start_time_millis_since_epoch)
        @current_player_state.uuid = player_uuid
        @current_player_state.play_seq_id = player_play_seq_id
        @current_player_state.song_is_playing = song_is_playing
        @current_player_state.start_time_millis_since_epoch = start_time_millis_since_epoch
        update_song_status
      end

      def update_song_status
        return if @desired_state.mode != MODE_PLAYER
        return if @current_player_state.uuid != @player_state.uuid
        return if @current_player_state.play_seq_id != @player_state.play_seq_id

        if @current_player_state.song_is_playing
          publish_trigger @current_player_state.start_time_millis_since_epoch
        else
          publish_no_trigger
        end
      end

      def publish_no_trigger
        @mqtt_service.publish_no_trigger
      end

      def publish_trigger(start_time_millis_since_epoch)
        @mqtt_service.publish_trigger @desired_state.sequence_guid, @desired_state.trigger_name,
                                      start_time_millis_since_epoch
      end
    end
  end
end
