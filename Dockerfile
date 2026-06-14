FROM ruby:3.2.2-slim

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    libvips \
    curl \
    git \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development' && \
    bundle install --jobs 4 --retry 3

COPY . .

RUN bundle exec bootsnap precompile --gemfile app/ lib/

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
