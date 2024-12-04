FROM ruby:3.3.6-alpine3.20

ENV LANG C.UTF-8

RUN apk add --update --no-cache build-base && \
apk add --update --no-cache tzdata && \
gem install bundler -v 2.3.6
