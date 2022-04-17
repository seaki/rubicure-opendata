FROM ruby:2.7.6-alpine3.15

ENV LANG C.UTF-8

RUN apk add --update --no-cache build-base && \
apk add --update --no-cache tzdata && \
gem install bundler -v 2.3.6
