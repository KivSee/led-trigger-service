# frozen_string_literal: true

require 'date'

module Kivsee
  module Trigger
    module Services
      # get time for trigger updates
      class TimeService
        def current_ms_since_epoch
          DateTime.now.strftime('%Q')
        end
      end
    end
  end
end
