FROM ruby:2.3.0
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs vim git
RUN mkdir /myapp
WORKDIR /myapp
ADD Gemfile* /myapp/
RUN bundle install
ADD . /myapp

# タイムゾーンファイルの変更(JST)
RUN cp /etc/localtime /etc/localtime.org
RUN ln -sf  /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

EXPOSE 3000
