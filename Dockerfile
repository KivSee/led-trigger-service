FROM ruby:3.0.3-slim
RUN apt-get update
RUN apt-get -y upgrade

# We'll be needing to compile native Ruby extensions (thin/EventMachine).
# Put it up here for re-use.
RUN apt-get -y install build-essential
RUN	gem install eventmachine
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
CMD ["ruby", "app/led_trigger_service.rb", "-o", "0.0.0.0"]