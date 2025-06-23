# Stage 1: Build stage
FROM ruby:3.3.7-slim AS builder

# Set environment variables
ARG RACK_ENV=production
ENV RACK_ENV=$RACK_ENV

# Install system dependencies: runtime and build dependencies
RUN set -x \
    && apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
        build-essential \
        curl \
        git \
        libffi-dev \
        libpq-dev \
        libsqlite3-dev \
        libxml2-dev \
        libxslt-dev \
        nodejs \
        npm \
        tzdata \
    && npm install -g yarn \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install Ruby gems
RUN set -x \
    && bundle config set --local without 'development test' \
    && bundle install --jobs 20 --retry 3 \
    # Remove unneeded files (cached *.gem, *.o, *.c)
    && rm -rf /usr/local/bundle/cache/*.gem \
    && find /usr/local/bundle/gems/ -name "*.c" -delete \
    && find /usr/local/bundle/gems/ -name "*.o" -delete

# Copy package.json and yarn.lock
COPY package.json yarn.lock ./

# Install JavaScript dependencies
RUN set -x \
    && yarn install \
    && rm -rf /tmp/*

# Copy the rest of the application
COPY . ./

# Precompile assets
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

# Stage 2: Final stage
FROM ruby:3.3.7-slim

# Set environment variables
ARG RACK_ENV=production
ENV RACK_ENV=$RACK_ENV

# Set the working directory
WORKDIR /app

# Copy the bundle from the builder stage
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
# Copy the application with precompiled assets from the builder stage
COPY --from=builder /app /app

# Create non-root user
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Set environment variables for production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true
ENV EXECJS_RUNTIME=Disabled

# Expose port 3000
EXPOSE 3000

# Define volume for SQLite database
VOLUME /app/db/sqlite

# Set the startup command
CMD ["./start.sh"]

