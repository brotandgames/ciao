FROM ruby:2.5.5

RUN apt-get update -qq && apt-get install -y build-essential apt-transport-https

RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash

RUN apt-get update -qq && apt-get install -y libxml2-dev libxslt1-dev nodejs yarn

# for postgres: libpq-dev
# for capybara-webkit: libqt4-webkit libqt4-dev xvfb

ENV APP_HOME=/app
ENV RACK_ENV=production
ENV RAILS_LOG_TO_STDOUT=true

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN gem update --system && gem install bundler

ADD Gemfile* package.json yarn.lock $APP_HOME/
# RUN bundle install --without development:test --path vendor/bundle --binstubs vendor/bundle/bin -j4 --deployment
RUN bundle install --without development:test --jobs 20

ADD . $APP_HOME

# The command '/bin/sh -c rake assets:precompile' needs the RAILS_MASTER_KEY to be set!?
# https://github.com/rails/rails/issues/32947
RUN SECRET_KEY_BASE=`bin/rake secret` rake assets:precompile

EXPOSE 3000

CMD ["./start.sh"]