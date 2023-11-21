# フロントエンドのベースイメージを設定
FROM node:14 AS frontend_base

# バックエンドのベースイメージを設定
FROM ruby:3.1.4 AS backend_base

# 環境変数を設定
ENV LANG C.UTF-8
ENV TZ="Asia/Tokyo"

# アプリケーションの依存関係をインストール
RUN apt-get update -qq && \
    apt-get install -y

# マルチステージビルドを使用してフロントエンドのビルドとバックエンドのビルドをまとめる
FROM frontend_base AS frontend
WORKDIR /app/frontend
COPY frontend/package.json .
COPY frontend/package-lock.json .
RUN npm install
COPY frontend .
RUN npm run build

FROM backend_base AS backend
WORKDIR /app/backend
COPY backend/Gemfile .
COPY backend/Gemfile.lock .
RUN bundle config set force_ruby_platform true && bundle install
COPY backend .

# 最終的なイメージのビルド
FROM backend_base
WORKDIR /app

# ビルド結果をコピー
COPY --from=frontend /app/frontend/dist ./frontend
COPY --from=backend /app/backend ./backend
