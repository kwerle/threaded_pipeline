# frozen_string_literal: true

require 'threaded_pipeline/version'

# Create a pipeline where each stage runs in its own thread.  Each stage must
# accept a single argument and will pass its result to the next stage.  The
# results of the last stage are then returned (unless opted out).
#
# = Example
#
#  threaded_pipeline = ThreadedPipeline.new
#  threaded_pipeline.stages << -> (url) { fetch_large_csv(url) }
#  threaded_pipeline.stages << -> (csv_data) { process_csv_data(csv_data) }
#  results = threaded_pipeline.process([list, of, large, csv, urls])
#
# = Example
#
#  another_pipeline = ThreadedPipeline.new(discard_results: true)
#  another_pipeline.stages << -> (url) { api_query(url) }
#  another_pipeline.stages << -> (returned_data) { process_returned_data(returned_data) }
#  another_pipeline.stages << -> (processed_results) { record_results_in_database(processed_results) }
#  while url = web_crawl_urls
#    another_pipeline.feed(url)
#  end
#  another_pipeline.finish
#
class ThreadedPipeline
  # Each stage will process the results of the previous one.
  #
  #   my_threaded_pipeline.stages << ->(arg) { process(arg) }
  attr_accessor :stages
  attr_reader   :started

  def initialize(discard_results: false)
    @stages = []
    @started = false
    @discard_results = discard_results
  end

  # The elements of enumerable will begin processing immediately.
  def process(enumerable)
    initialize_run
    initialize_first_queue(enumerable)
    finish
  end

  # Process the enumerale list without using threads.
  # Maybe you have a bug you want to work on without threading.  Or you have a
  # benchmark you want to run.
  def process_unthreaded(enumerable)
    initialize_run
    @results = enumerable.map do |element|
      stages.each do |stage|
        element = stage[element]
      end
      element
    end
    finish
  end

  # Add another element to the list of work to be processed.  Work will start
  # on the first element immediately (only feed once you have all your stages added).
  # You could use .process if you already have the full list.
  # This method is not thread safe (wrap access in a mutex if feeding from
  # multiple threads).
  def feed(element)
    initialize_run unless @started
    queue_hash[stages.first] << element
  end

  # Wait for all the threads to finish and return the results.
  # @return results of last stage (unless discard_results was set to true)
  def finish
    raise "You never started pipeline #{inspect}" unless @started

    queue_hash[stages.first] << finish_object
    @threads.each(&:join)
    @started = false
    @queue_hash = nil
    @finish_object = nil
    @results unless @discard_results
  end

  private

  def initialize_run
    raise "Already started pipeline #{inspect}" if @started

    @started = true
    @threads = []
    @results = []
    stages.each_with_index do |stage, index|
      @threads << Thread.new do
        # Grab the next element off our queue
        while (element = queue_hash[stage].pop) != finish_object
          # The way you call a lambda is with []'s.  Who knew?
          result = stage[element]
          if index == stages.count - 1
            # Only one thread is accessing @results
            @results << result unless @discard_results
          else
            queue_hash[stages[index + 1]] << result
          end
        end
        queue_hash[stages[index + 1]] << finish_object unless index == stages.count - 1
      end
    end
  end

  def initialize_first_queue(enumerable)
    first_queue = queue_hash[stages.first]
    enumerable.each do |element|
      first_queue << element
    end
    first_queue << finish_object
  end

  # one queue after each stage but the last
  def queue_hash
    return @queue_hash unless @queue_hash.nil?

    @queue_hash = stages.map { |stage| [stage, Queue.new] }.to_h
  end

  # How we know we're done?
  def finish_object
    @finish_object ||= Object.new
  end
end
