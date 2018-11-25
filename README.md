# ThreadedPipeline

Recently I have been doing a lot of the pattern:
1. Download file from list of URLs
1. Process file
1. Record results

Part 1 is network bound.  Part 2 is CPU bound.  Part 3 is service bound (database in my case).  There is no reason I should not run these three in parallel, so this gem is the encapsulation of the general pattern of running parts of a pipeline in parallel.

Greatly inspired by the [parallel gem](https://github.com/grosser/parallel).

Tested with MRI and JRuby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'threaded_pipeline'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install threaded_pipeline

## Usage

```
threaded_pipeline = ThreadedPipeline.new
threaded_pipeline.stages << -> (url) { fetch_large_csv(url) }
threaded_pipeline.stages << -> (local_file) { process_local_file(local_file) }
threaded_pipeline.stages << -> (processed_results) { record_results_in_database(processed_results) }
results = threaded_pipeline.process([list, of, large, csv, urls])
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/threaded_pipeline.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
