# frozen_string_literal: true
# # frozen_string_literal: true

# require 'minitest/autorun'
# require 'trigger_state'

# describe 'Kivsee::Trigger::TriggerState' do
#   let(:time_mock) { Minitest::Mock.new }
#   let(:uuid) { '12345' }
#   let(:uuid2) { '67890' }
#   let(:trigger_name) { 'foo' }
#   let(:led_sequence_guid) { '111' }

#   describe 'song trigger' do
#     it 'should update state on mqtt once offset is received' do
#       mqtt_mock = Minitest::Mock.new

#       trigger_state = Kivsee::Trigger::TriggerState.new mqtt_mock, time_mock
#       trigger_state.set_song trigger_name, led_sequence_guid, uuid, 1

#       mqtt_mock.expect :publish_trigger, nil, [led_sequence_guid, trigger_name, 1000]
#       trigger_state.player_offset_update uuid, 1, 1000

#       assert_mock mqtt_mock
#     end

#     it 'should send addtional offset update when received' do
#       mqtt_mock = Minitest::Mock.new

#       trigger_state = Kivsee::Trigger::TriggerState.new mqtt_mock, time_mock
#       trigger_state.set_song trigger_name, led_sequence_guid, uuid, 1

#       mqtt_mock.expect :publish_trigger, nil, [led_sequence_guid, trigger_name, 1000]
#       trigger_state.player_offset_update uuid, 1, 1000

#       mqtt_mock.expect :publish_trigger, nil, [led_sequence_guid, trigger_name, 2000]
#       trigger_state.player_offset_update uuid, 1, 2000

#       assert_mock mqtt_mock
#     end

#     it 'should ignore offset of old song' do
#       mqtt_mock = Minitest::Mock.new

#       trigger_state = Kivsee::Trigger::TriggerState.new mqtt_mock, time_mock
#       trigger_state.set_song trigger_name, led_sequence_guid, uuid, 2
#       trigger_state.player_offset_update uuid, 1, 1000

#       assert_mock mqtt_mock
#     end

#     it 'should report offset received before song' do
#       mqtt_mock = Minitest::Mock.new

#       trigger_state = Kivsee::Trigger::TriggerState.new mqtt_mock, time_mock
#       trigger_state.player_offset_update uuid, 1, 1000

#       mqtt_mock.expect :publish_trigger, nil, [led_sequence_guid, trigger_name, 1000]
#       trigger_state.set_song trigger_name, led_sequence_guid, uuid, 1

#       assert_mock mqtt_mock
#     end

#     it 'should report last offset of multiple future reports' do
#       mqtt_mock = Minitest::Mock.new

#       trigger_state = Kivsee::Trigger::TriggerState.new mqtt_mock, time_mock
#       trigger_state.player_offset_update uuid, 2, 1000
#       trigger_state.player_offset_update uuid, 2, 2000
#       mqtt_mock.expect :publish_trigger, nil, [led_sequence_guid, trigger_name, 2000]
#       trigger_state.set_song trigger_name, led_sequence_guid, uuid, 2

#       assert_mock mqtt_mock
#     end

#     it 'should ignore future offset of different player uuid' do
#       mqtt_mock = Minitest::Mock.new

#       trigger_state = Kivsee::Trigger::TriggerState.new mqtt_mock, time_mock
#       trigger_state.player_offset_update uuid2, 2, 1000
#       trigger_state.set_song trigger_name, led_sequence_guid, uuid, 2

#       assert_mock mqtt_mock
#     end
#   end

#   describe 'non song trigger' do
#     it 'should update state on non song trigger with current time' do
#       mqtt_mock = Minitest::Mock.new
#       time_mock = Minitest::Mock.new
#       fake_current_ms_since_epoch = 777

#       trigger_state = Kivsee::Trigger::TriggerState.new mqtt_mock, time_mock
#       time_mock.expect :current_ms_since_epoch, fake_current_ms_since_epoch, []
#       mqtt_mock.expect :publish_trigger, nil, [led_sequence_guid, trigger_name, fake_current_ms_since_epoch]
#       trigger_state.set_trigger trigger_name, led_sequence_guid

#       assert_mock mqtt_mock
#       assert_mock time_mock
#     end
#   end
# end
