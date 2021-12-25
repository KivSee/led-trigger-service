# frozen_string_literal: true

require 'opentelemetry/sdk'
require 'opentelemetry/exporter/jaeger'

require 'opentelemetry/instrumentation/sinatra'
require 'opentelemetry/instrumentation/faraday'

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'led-trigger'
  c.use 'OpenTelemetry::Instrumentation::Sinatra'
  c.use 'OpenTelemetry::Instrumentation::Faraday'
end
