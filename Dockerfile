# ruby:alpine does not play well with rubocop
FROM ruby

WORKDIR /threaded_pipeline

COPY *.gemspec ./
COPY Gemfile* ./
COPY lib/threaded_pipeline/version.rb lib/threaded_pipeline/version.rb

RUN bundle -j 6

CMD bundle console
