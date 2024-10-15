FROM ruby:3.3.5-slim

RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
    build-essential \
    git \
    sqlite3 \
    yarn \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3 \
  RAILS_ENV=production

RUN gem update --system && gem install bundler

WORKDIR /app

COPY Gemfile* .ruby-version /app/
RUN bundle config frozen true \
 && bundle config jobs 4 \
 && bundle config deployment true \
 && bundle config without 'development test' \
 && bundle install

COPY package.json yarn.lock /app/
RUN set -x \
    && yarn install \
    && rm -rf /tmp/*

COPY . ./

# Precompile assets
# SECRET_KEY_BASE or RAILS_MASTER_KEY is required in production, but we don't
# want real secrets in the image or image history. The real secret is passed in
# at run time
ARG SECRET_KEY_BASE=fakekeyforassets
RUN bin/rails assets:clobber && bundle exec rails assets:precompile

EXPOSE 3000

ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true
ENV EXECJS_RUNTIME=Disabled

VOLUME /app/db/sqlite

CMD ["./start.sh"]
