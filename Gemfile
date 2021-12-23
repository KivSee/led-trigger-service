# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'sinatra', '~> 2.1'
gem 'faraday', '~> 1.8'
gem 'json', '~> 2.6'
gem 'mqtt', '~> 0.5.0'
gem 'dotenv', '~> 2.7'
gem 'rake', '~> 13.0'
gem 'faye-websocket', '~> 0.11.1'
gem 'celluloid', '~> 0.18.0'
gem "puma", "~> 5.5"

group :development do
    gem 'rubocop', '~> 1.23', require: false
end

group :test, :development do
    gem 'minitest', '~> 5.14'
end



