# ruby:alpine does not play well with rubocop
FROM ruby

WORKDIR /pipelines

COPY *.gemspec ./
COPY Gemfile* ./
COPY lib/pipelines/version.rb lib/pipelines/version.rb

RUN bundle -j 6

CMD bundle console
