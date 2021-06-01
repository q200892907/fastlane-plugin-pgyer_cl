module Fastlane
  module Helper
    class PgyerClHelper
      # class methods that you define here become available in your action
      # as `Helper::PgyerClHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the pgyer_cl plugin helper!")
      end
    end
  end
end
