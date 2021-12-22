# frozen_string_literal: true

require 'faraday'
require 'json'

module Kivsee
  module Trigger
    module Services
      # interact with the service that manages led sequences configuration
      class LedSequenceService
        def initialize(seq_service_host, seq_service_port)
          @clinet = Faraday.new(url: "http://#{seq_service_host}:#{seq_service_port}") do |faraday|
            faraday.request :url_encoded # form-encode POST params
            faraday.response :logger                  # log requests to STDOUT
            faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
          end
        end

        def latest_led_sequence_guid(trigger_name)
          response = @clinet.get "/triggers/#{trigger_name}/guid"
          data = JSON.parse response.body
          data['guid']
        end
      end
    end
  end
end
