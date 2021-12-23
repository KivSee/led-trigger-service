# frozen_string_literal: true

require 'faraday'
require 'json'

module Kivsee
  module Trigger
    module Services
      # interact with the player to play and stop audio
      class PlayerService
        def initialize(player_service_host, player_service_port)
          @clinet = Faraday.new(url: "http://#{player_service_host}:#{player_service_port}") do |faraday|
            faraday.request :url_encoded # form-encode POST params
            faraday.response :logger                  # log requests to STDOUT
            faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
          end
        end

        def play_song(song_name, start_offset_ms)
          res = @clinet.put('/api/current-song',
                            { "file_id": "/#{song_name}.wav", "start_offset_ms": start_offset_ms }.to_json)
          return res.success?, JSON.parse(res.body)
        rescue => e
          return false, {"operation_desc" => e.message}
        end

        def stop
          res = @clinet.put('/api/current-song',
                            {}.to_json)
          JSON.parse res.body
        rescue => e
          return false, {"operation_desc" => e.message}
        end
      end
    end
  end
end
