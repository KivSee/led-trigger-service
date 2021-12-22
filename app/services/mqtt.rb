# frozen_string_literal: true

require 'mqtt'

module Kivsee
  module Trigger
    module Services
      # access the system mqtt broker to communicate with other components and things
      class MqttService
        TOPIC_NAME = 'trigger'
        private_constant :TOPIC_NAME

        def initialize(broker_url)
          @client = MQTT::Client.connect(broker_url)
        end

        def publish_trigger(sequence_guid, trigger_name, start_time_ms_since_epoch)
          trigger_msg = JSON.generate({
                                        guid: sequence_guid,
                                        trigger_name: trigger_name,
                                        start_time_ms_since_epoch: start_time_ms_since_epoch
                                      })
          @client.publish(TOPIC_NAME, trigger_msg, true, 1)
        end

        def publish_no_trigger
          @client.publish(TOPIC_NAME, JSON.generate({}), true, 1)
        end
      end
    end
  end
end
