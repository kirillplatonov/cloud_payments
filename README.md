# CloudPayments

CloudPayments ruby client (https://developers.cloudpayments.ru/en/)

[![Build Status](https://travis-ci.org/platmart/cloud_payments.svg)](https://travis-ci.org/platmart/cloud_payments)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cloud_payments'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install cloud_payments
```

## Usage

### Configuration

#### Global configuration

```ruby
CloudPayments.configure do |c|
  c.host = 'http://localhost:3000'    # By default, it is https://api.cloudpayments.ru
  c.public_key = ''
  c.secret_key = ''
  c.log = false                       # By default. it is true
  c.logger = Logger.new('/dev/null')  # By default, it writes logs to stdout
  c.raise_banking_errors = true       # By default, it is not raising banking errors
end

# API client
CloudPayments.client.payments.cards.charge(...)

# Webhooks
CloudPayments.webhooks.on_pay(...)
```

#### Local configuration

```ruby
config = CloudPayments::Config.new do |c|
  # ...
end

# API client
client = CloudPayments::Client.new(config)
client.payments.cards.charge(...)

# Webhooks
webhooks = CloudPayments::Webhooks.new(config)
webhooks.on_pay(...)
```

### Test method

```ruby
CloudPayments.client.ping
# => true
```

### Cryptogram-based payments

```ruby
transaction = CloudPayments.client.payments.cards.charge(
  amount: 120,
  currency: 'RUB',
  ip_address: request.remote_ip,
  name: params[:name],
  card_cryptogram_packet: params[:card_cryptogram_packet]
)
# => {:metadata=>nil,
# :id=>12345,
# :amount=>120,
# :currency=>"RUB",
# :currency_code=>0,
# :invoice_id=>"1234567",
# :account_id=>"user_x",
# :email=>nil,
# :description=>"Payment for goods on example.com",
# :created_at=>#<DateTime: 2014-08-09T11:49:41+00:00 ((2456879j,42581s,0n),+0s,2299161j)>,
# :authorized_at=>#<DateTime: 2014-08-09T11:49:42+00:00 ((2456879j,42582s,0n),+0s,2299161j)>,
# :confirmed_at=>#<DateTime: 2014-08-09T11:49:42+00:00 ((2456879j,42582s,0n),+0s,2299161j)>,
# :auth_code=>"123456",
# :test_mode=>true,
# :ip_address=>"195.91.194.13",
# :ip_country=>"RU",
# :ip_city=>"Ufa",
# :ip_region=>"Bashkortostan Republic",
# :ip_district=>"Volga Federal District",
# :ip_lat=>54.7355,
# :ip_lng=>55.991982,
# :card_first_six=>"411111",
# :card_last_four=>"1111",
# :card_type=>"Visa",
# :card_type_code=>0,
# :issuer=>"Sberbank of Russia",
# :issuer_bank_country=>"RU",
# :status=>"Completed",
# :status_code=>3,
# :reason=>"Approved",
# :reason_code=>0,
# :card_holder_message=>"Payment successful",
# :name=>"CARDHOLDER NAME",
# :token=>"a4e67841-abb0-42de-a364-d1d8f9f4b3c0"}
transaction.class
# => CloudPayments::Transaction
transaction.token
# => "a4e67841-abb0-42de-a364-d1d8f9f4b3c0"
```

## Kassa Receipt

CloudPayments Kassa API (https://cloudpayments.ru/docs/api/kassa)

```ruby
CloudPayments.client.kassa.receipt({
  account_id: "user@example.com",
  customer_receipt: {
    items: [
      {
        amount: "13350.00",
        ean13: nil,
        label: "Good Description",
        price: "13350.00",
        quantity: 1.0,
        vat: nil
      }
    ]
  },
  inn: "7708806666",
  invoice_id: "231312312",
  type: "Income"
})
```

## Apple Pay Start Session
[Start Apple Pay session](https://developers.cloudpayments.ru/#zapusk-sessii-dlya-oplaty-cherez-apple-pay)
```ruby
CloudPayments.client.apple_pay.start_session({validation_url: "https://apple-pay-gateway-pr-pod2.apple.com/paymentservices/startSession"})
# => {
#   :message => nil,
#     :model => {
#                    :display_name => "example.com,
#                     :domain_name => "example.com",
#                 :epoch_timestamp => 1594072416294,
#                      :expires_at => 1594076016294,
#             :merchant_identifier => "5DCCE3A52CFC3FAF9F4EA8421472E47BC503E03051B04D2ED67A3834386B52F2",
#     :merchant_session_identifier => "SSHDA3C703BD69B45EDB8934E6BFCC159B2B83AAFC02DB625F1F1E3997CCC2FE2CFD11F636558",
#                           :nonce => "51c77142",
#                       :signature => "30800.....0"
#   },
#   :success => true
# }

```

## Webhooks

```ruby
if CloudPayments.webhooks.data_valid?(payload, hmac_token)
  event = CloudPayments.webhooks.on_recurrent(payload)
  # or
  event = CloudPayments.webhooks.on_pay(payload)
  # or
  event = CloudPayments.webhooks.on_fail(payload)
end
```

with capturing of an exception

```ruby
rescue_from CloudPayments::Webhooks::HMACError, :handle_hmac_error

before_action -> { CloudPayments.webhooks.validate_data!(payload, hmac_token) }

def pay
  event = CloudPayments.webhooks.on_pay(payload)
  # ...
end

def fail
  event = CloudPayments.webhooks.on_fail(payload)
  # ...
end

def recurrent
  event = CloudPayments.webhooks.on_recurrent(payload)
  # ...
end
```

## Contributing

1. Fork it ( https://github.com/platmart/cloud_payments/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
