# frozen_string_literal: true

require 'faraday'
require 'json'

module Kivsee
  module Trigger
    module Services
      class PlayerService
        def initialize(player_service_host, player_service_port)
          @clinet = Faraday.new(url: "http://#{player_service_host}:#{player_service_port}") do |faraday|
            faraday.request :url_encoded # form-encode POST params
            faraday.response :logger                  # log requests to STDOUT
            faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
          end
        end

        def play_song(song_name)
          res = @clinet.put('/api/current-song',
                            { "file_id": "/#{song_name}.wav", "start_offset_ms": 0 }.to_json)
          JSON.parse res.body
        end
      end
    end
  end
end
