# ベース: Debian slim（aarch64-linux）
FROM ruby:3.3-slim AS build

# 必要パッケージ（← psychに必要なlibyaml-devとpkg-configを追加）
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential git curl \
      libpq-dev \
      nodejs \
      yarnpkg \
      pkg-config \
      libyaml-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 先にGemfile系だけコピー（キャッシュ最適化）
COPY Gemfile Gemfile.lock ./

# プラットフォームをロック（念のため二重化）
RUN gem install bundler && bundle lock --add-platform aarch64-linux || true

# 依存インストール
RUN bundle install && \
    rm -rf ~/.bundle/ /usr/local/bundle/ruby/*/cache /usr/local/bundle/ruby/*/bundler/gems/*/.git

# ---- 本体投入
COPY . .

# 本番(実行)イメージ（開発用でもこれでOK）
FROM ruby:3.3-slim

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      libvips \
      postgresql-client \
      libyaml-0-2 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

ENV RAILS_ENV=development
EXPOSE 3000
CMD ["bash", "-lc", "bin/rails db:prepare && bin/rails s -b 0.0.0.0 -p 3000"]
