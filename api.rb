#! /usr/bin/env ruby

require 'bundler/setup'
require 'pit'
require 'oauth'
require 'zaim'

PIT_NAME = "ZaimCommand"

# default value
# Pit.set(PIT_NAME, {
#     :data => {
#         :consumer_key    => YOUR_CONSUMER_KEY,
#         :consumer_secret => YOUR_CONSUMER_SECRET
#     }
# })

def get_token
    config = Pit.get(PIT_NAME)
    consumer = OAuth::Consumer.new(config[:consumer_key], config[:consumer_secret],
                                   :site => 'https://api.zaim.net',
                                   :authorize_url => 'https://auth.zaim.net/users/auth',
                                   :request_token_path => '/v2/auth/request',
                                   :access_token_path => '/v2/auth/access'
                                  )

    request_token = consumer.get_request_token()

    puts "以下の URL にアクセスして、code をコピペしてください"
    puts request_token.authorize_url()
    verifier = gets.chomp

    access_token = request_token.get_access_token(:oauth_verifier => verifier)

    Pit.set(PIT_NAME, {
        :data => {
            :consumer_key    => config[:consumer_key],
            :consumer_secret => config[:consumer_secret],
            :oauth_token     => access_token.token,
            :oauth_secret    => access_token.secret
        }
    })
end

config = Pit.get(PIT_NAME)

if config[:oauth_token].nil? or  config[:oauth_secret].nil?
    get_token
    config = Pit.get(PIT_NAME)
end

Zaim.configure do |c|
    c.consumer_key       = config[:consumer_key]
    c.consumer_secret    = config[:consumer_secret]
    c.oauth_token        = config[:oauth_token]
    c.oauth_token_secret = config[:oauth_secret]
end

client = Zaim::Client.new

