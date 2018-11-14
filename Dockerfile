FROM ruby:2.5

ENV APP_PATH /sga-services

RUN mkdir -p $APP_PATH

WORKDIR $APP_PATH

ADD Gemfile $APP_PATH/Gemfile

ADD Gemfile.lock $APP_PATH/Gemfile.lock

RUN bundle install

ADD . $APP_PATH

EXPOSE 80

CMD puma -p 80