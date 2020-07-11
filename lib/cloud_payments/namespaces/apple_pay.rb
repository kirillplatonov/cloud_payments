# frozen_string_literal: true
module CloudPayments
  module Namespaces
    class ApplePay < Base
      ValidationUrlMissing = Class.new(StandardError)

      def self.resource_name
        'applepay'
      end

      def start_session(attributes)
        validation_url = attributes.fetch(:validation_url) { raise ValidationUrlMissing.new('validation_url is required') }

        request(:startsession, { "ValidationUrl" => validation_url })
      end
    end
  end
end
