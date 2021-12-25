# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'celluloid', '~> 0.18.0'
gem 'dotenv', '~> 2.7'
gem 'faraday', '~> 1.8'
gem 'faye-websocket', '~> 0.11.1'
gem 'json', '~> 2.6'
gem 'mqtt', '~> 0.5.0'
gem 'puma', '~> 5.5'
gem 'rake', '~> 13.0'
gem 'sinatra', '~> 2.1'
gem 'sinatra-contrib', '~> 2.1'

group :development do
  gem 'rubocop', '~> 1.23', require: false
end

group :test, :development do
  gem 'minitest', '~> 5.14'
end

gem 'opentelemetry-sdk', '~> 1.0'

gem 'opentelemetry-exporter-jaeger', '~> 0.20.1'

gem 'opentelemetry-instrumentation-sinatra', '~> 0.19.3'

gem 'opentelemetry-instrumentation-faraday', '~> 0.19.3'
