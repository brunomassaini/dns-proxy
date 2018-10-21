FROM ruby:2.5

ENV APP_HOME /usr/src/app
WORKDIR $APP_HOME

COPY Gemfile* $APP_HOME/

RUN gem install bundler --no-document \
  && bundle install

COPY lib/ $APP_HOME/lib/
COPY challanger $APP_HOME/
RUN chmod +x challanger

ENTRYPOINT ["/usr/src/app/challanger"]
