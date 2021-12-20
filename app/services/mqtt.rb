# frozen_string_literal: true

require 'mqtt'

module Kivsee
  module Trigger
    module Services
      class MqttService
        TOPIC_NAME = 'trigger'
        private_constant :TOPIC_NAME

        def initialize(broker_ip)
          @client = MQTT::Client.connect(broker_ip)
        end

        def publish_trigger(sequence_guid, trigger_name, start_time_ms_since_epoch)
          trigger_msg = JSON.generate({
                                        guid: sequence_guid,
                                        trigger_name: trigger_name,
                                        start_time_ms_since_epoch: start_time_ms_since_epoch
                                      })
          @client.publish(TOPIC_NAME, trigger_msg, true, 1)
        end
      end
    end
  end
end
