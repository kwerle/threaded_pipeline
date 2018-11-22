# frozen_string_literal: true

require 'threaded_pipeline/version'

# Be awesome
class ThreadedPipeline
  attr_accessor :stages
  attr_reader   :started

  def initialize(stages = [])
    @stages = stages
    @started = false
  end

  def process(enumerable)
    initialize_run
    initialize_first_queue(enumerable)
    finish
  end

  def feed(element)
    initialize_run unless @started
    queue_hash[stages.first] << element
  end

  def finish
    raise "You never started pipeline #{inspect}" unless @started

    queue_hash[stages.first] << finish_object
    @threads.each(&:join)
    @started = false
    @queue_hash = nil
    @finish_object = nil
    @results
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
            @results << result
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
