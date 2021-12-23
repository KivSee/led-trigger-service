FROM ruby:3.0.3-alpine AS builder
RUN apk update
RUN apk add --no-cache g++ gcc make musl-dev
RUN	gem install eventmachine
COPY Gemfile Gemfile.lock ./
RUN bundle config set without 'development test'
RUN bundle install

FROM ruby:3.0.3-alpine
WORKDIR /app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY . .
CMD ["ruby", "app/led_trigger_service.rb", "-o", "0.0.0.0"]