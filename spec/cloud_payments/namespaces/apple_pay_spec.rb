#!/usr/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

describe CloudPayments::Namespaces::ApplePay do
  subject{ described_class.new(CloudPayments.client) }

  describe '#receipt' do
    let(:attributes) do
      {
        validation_url: ''
      }
    end

    context do
      before{ attributes.delete(:validation_url) }
      specify{ expect{subject.start_session(attributes)}.to raise_error(described_class::ValidationUrlMissing) }
    end
  end
end
