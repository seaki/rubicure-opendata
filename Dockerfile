FROM ruby:2.7.2-alpine3.11

ENV LANG C.UTF-8
ENV APP_ROOT /usr/src/rubicure-opendata

RUN mkdir ${APP_ROOT}
WORKDIR ${APP_ROOT}

COPY Gemfile ${APP_ROOT}/Gemfile
COPY Gemfile.lock ${APP_ROOT}/Gemfile.lock

RUN apk add --update --no-cache --virtual=.build-dependencies build-base && \
apk add --update --no-cache tzdata && \
bundle install && \
apk del .build-dependencies

COPY . ${APP_ROOT}

EXPOSE 4567
CMD ["ruby", "app.rb", "-o", "0.0.0.0"]
