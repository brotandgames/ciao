FROM ruby:2.6.3-alpine

# for postgres: postgresql-dev
RUN apk add --no-cache \
        sqlite-dev \
        tzdata \
        yarn

WORKDIR /app

ARG RACK_ENV=production
ENV RACK_ENV=$RACK_ENV

ADD Gemfile* /app/
RUN set -x \
    && apk add --no-cache --virtual .build-deps \
        build-base \
        libxml2-dev \
        libxslt-dev \
    && gem install bundler \
    && bundle install --without development:test --jobs 20 -j"$(nproc)" --retry 3 \
    # Remove unneeded files (cached *.gem, *.o, *.c)
    && rm -rf \
        /usr/local/bundle/cache/*.gem \
        /usr/local/bundle/gems/**/*.c \
        /usr/local/bundle/gems/**/*.o \
    && apk del .build-deps

COPY package.json yarn.lock /app/
RUN set -x \
    && yarn install \
    && rm -rf /tmp/*

COPY . ./

# The command '/bin/sh -c rake assets:precompile' needs the RAILS_MASTER_KEY to be set!?
# https://github.com/rails/rails/issues/32947
RUN set -x \
    && SECRET_KEY_BASE=foo bundle exec rake assets:precompile \
    # Remove folders not needed in resulting image
    && rm -rf \
        /tmp/* \
        app/assets \
        lib/assets \
        node_modules \
        spec \
        tmp/cache \
        vendor/assets

ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true
ENV EXECJS_RUNTIME=Disabled

EXPOSE 3000

VOLUME /app/db/sqlite

CMD ["./start.sh"]
