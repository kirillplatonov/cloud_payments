# frozen_string_literal: true
require 'cloud_payments/client/errors'
require 'cloud_payments/client/gateway_errors'
require 'cloud_payments/client/response'
require 'cloud_payments/client/serializer'

module CloudPayments
  class Client
    include Namespaces

    attr_reader :config, :connection

    def initialize(config = nil)
      @config = config || CloudPayments.config
      @connection = build_connection
    end

    def perform_request(path, params = nil)
      response = connection.post(path, (params ? convert_to_json(params) : nil), headers)

      Response.new(response.status, response.body, response.headers).tap do |response|
        raise_transport_error(response) if response.status.to_i >= 300
      end
    end

    private

    def convert_to_json(data)
      config.serializer.dump(data)
    end

    def headers
      { 'Content-Type' => 'application/json' }
    end

    def logger
      config.logger
    end

    def raise_transport_error(response)
      logger.fatal "[#{response.status}] #{response.origin_body}" if logger
      error = ERRORS[response.status] || ServerError
      raise error.new "[#{response.status}] #{response.origin_body}"
    end

    def build_connection
      Faraday::Connection.new(config.host, config.connection_options) do |conn|

        # https://github.com/lostisland/faraday/blob/main/UPGRADING.md#authentication-helper-methods-in-connection-have-been-removed
        # https://lostisland.github.io/faraday/#/middleware/included/authentication?id=faraday-1x-usage
        if Faraday::VERSION.start_with?("1.")
          conn.request :basic_auth, config.public_key, config.secret_key
        else
          conn.request :authorization, :basic, config.public_key, config.secret_key
        end

        config.connection_block.call(conn) if config.connection_block
      end
    end
  end
end
