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

    # It seems that celluloid future signal function accepts an undocumented parameter
    # that is an object that return it's value from a 'value' attribute 
    # e.g. `response.value` should return what we actually want to resolve the future to.
    #
    # I wish it was documented but this is how I got it to work.
    # celluloid seems not active or well maintained 
    # but it would be great to open an issue one day to clarify how to use future object correctly.
    class SongComplitionFutrueResult
      attr_reader :value

      def initialize(value)
        @value = value
      end
    end

    # monitor the desired vs current state of the trigger and send updates when needed
    class TriggerState
      include Celluloid

      def initialize(mqtt_service)
        @mqtt_service = mqtt_service

        @player_latest_request = PlayerState.new
        @desired_state = DesiredState.new
        @current_player_state = CurrentPlayerState.new
        @song_wait_future = nil
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
      def set_song(trigger_name, sequence_guid, player_uuid, player_play_seq_id, return_on_completion)

        signal_previous_waiters_on_new_song

        @player_latest_request.uuid = player_uuid
        @player_latest_request.play_seq_id = player_play_seq_id

        @desired_state.trigger_name = trigger_name
        @desired_state.sequence_guid = sequence_guid
        @desired_state.mode = MODE_PLAYER

        update_song_status

        if return_on_completion
          @song_wait_future = Celluloid::Future.new
          reason_for_termination = @song_wait_future.value
          @song_wait_future = nil
          return reason_for_termination
        else
          return nil
        end
      end

      def player_offset_update(player_uuid, player_play_seq_id, song_is_playing, start_time_millis_since_epoch)
        @current_player_state.uuid = player_uuid
        @current_player_state.play_seq_id = player_play_seq_id
        @current_player_state.song_is_playing = song_is_playing
        @current_player_state.start_time_millis_since_epoch = start_time_millis_since_epoch

        update_song_status

        waiting_for_song = @song_wait_future != nil

        signal_previous_waiters_on_player_update player_uuid, player_play_seq_id, song_is_playing

      end

      def update_song_status
        return if @desired_state.mode != MODE_PLAYER
        return if @current_player_state.uuid != @player_latest_request.uuid
        return if @current_player_state.play_seq_id != @player_latest_request.play_seq_id

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

      def signal_previous_waiters_on_new_song
        if @song_wait_future == nil
          return
        end

        @song_wait_future.signal(SongComplitionFutrueResult.new "song is completed because a new one was started.")
        @song_wait_future = nil
      end

      def signal_previous_waiters_on_player_update(player_uuid, player_play_seq_id, song_is_playing)
        if @song_wait_future == nil
          return nil
        end

        if @current_player_state.uuid != player_uuid
          @song_wait_future.signal(SongComplitionFutrueResult.new "detected a new player uuid. previous song no longer relevant")
          @song_wait_future = nil
          return
        end
        
        if player_play_seq_id > @player_latest_request.play_seq_id
          @song_wait_future.signal(SongComplitionFutrueResult.new "a new song is playing")
          @song_wait_future = nil
          return
        end

        if !song_is_playing
          @song_wait_future.signal(SongComplitionFutrueResult.new "song reached its end and is no longer playing.")
          @song_wait_future = nil
          return
        end
      end
    end
  end
end
