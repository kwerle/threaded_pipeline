# frozen_string_literal: true

require 'test_helper'

class PipelinesTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Pipelines::VERSION
  end

  def test_new_should_work
    pipeline = Pipelines.new
    refute_nil pipeline
  end

  def test_stages_should_work
    pipeline = Pipelines.new
    pipeline.stages
  end

  def test_add_stage_should_work
    pipeline = Pipelines.new
    pipeline.stages << ->(arg) { arg }
  end

  def test_processing
    pipeline = Pipelines.new
    pipeline.stages << ->(arg) { arg + 1 }
    pipeline.stages << ->(arg) { arg + 2 }
    results = pipeline.process([1, 2])
    assert_equal([4, 5], results)
  end

  def test_performance
    pipeline = Pipelines.new
    sleep_time = 0.1
    pipeline.stages << ->(arg) { sleep(sleep_time); arg + 1 }
    pipeline.stages << ->(arg) { sleep(sleep_time); arg + 1 }
    pipeline.stages << ->(arg) { sleep(sleep_time); arg + 1 }
    start_time = Time.now
    results = pipeline.process([1, 2, 3, 4, 5])
    end_time = Time.now
    assert_equal([4, 5, 6, 7, 8], results)
    # We're doing 3 stages, so it should not be quite 3 times as fast
    assert_operator(sleep_time * results.count * pipeline.stages.count / 2.0, :>, end_time - start_time)
  end

  def test_feeding
    pipeline = Pipelines.new
    pipeline.stages << ->(arg) { arg + 1 }
    pipeline.stages << ->(arg) { arg + 2 }
    pipeline.feed(1)
    pipeline.feed(2)
    results = pipeline.finish
    assert_equal([4, 5], results)
  end

  def test_double_start_fails
    pipeline = Pipelines.new
    pipeline.stages << ->(arg) { arg + 1 }
    pipeline.stages << ->(arg) { arg + 2 }
    pipeline.feed(1)
    assert_raises(RuntimeError) { pipeline.process([2]) }
  end

  def test_double_run_works
    pipeline = Pipelines.new
    pipeline.stages << ->(arg) { arg + 1 }
    pipeline.stages << ->(arg) { arg + 2 }
    results = pipeline.process([1, 2])
    assert_equal([4, 5], results)
    results = pipeline.process([1, 2])
    assert_equal([4, 5], results)
    pipeline.feed(1)
    pipeline.feed(2)
    results = pipeline.finish
    assert_equal([4, 5], results)
  end

end
