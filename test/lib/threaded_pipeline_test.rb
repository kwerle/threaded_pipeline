# frozen_string_literal: true

require 'test_helper'

class ThreadedPipelineTest < Minitest::Test
  def two_stage_pipeline(*args)
    pipeline = ThreadedPipeline.new(*args)
    pipeline.stages << ->(arg) { arg + 1 }
    pipeline.stages << ->(arg) { arg * 2 }
    pipeline
  end

  def test_that_it_has_a_version_number
    refute_nil ::ThreadedPipeline::VERSION
  end

  def test_new_should_work
    pipeline = ThreadedPipeline.new
    refute_nil pipeline
  end

  def test_stages_should_work
    pipeline = ThreadedPipeline.new
    pipeline.stages
  end

  def test_add_stage_should_work
    pipeline = ThreadedPipeline.new
    pipeline.stages << ->(arg) { arg }
  end

  def test_processing
    pipeline = two_stage_pipeline
    results = pipeline.process([1, 2])
    assert_equal([4, 6], results)
  end

  def test_performance
    pipeline = ThreadedPipeline.new
    sleep_time = 0.1
    pipeline.stages << ->(arg) { sleep(sleep_time); arg + 1 }
    pipeline.stages << ->(arg) { sleep(sleep_time); arg * 2 }
    pipeline.stages << ->(arg) { sleep(sleep_time); arg + 3 }
    start_time = Time.now
    results = pipeline.process([1, 2, 3, 4, 5])
    end_time = Time.now
    assert_equal([7, 9, 11, 13, 15], results)
    # We're doing 3 stages, so it should not be quite 3 times as fast
    assert_operator(sleep_time * results.count * pipeline.stages.count / 2.0, :>, end_time - start_time)
  end

  def test_feeding
    pipeline = two_stage_pipeline
    pipeline.feed(1)
    pipeline.feed(2)
    results = pipeline.finish
    assert_equal([4, 6], results)
  end

  def test_double_start_fails
    pipeline = two_stage_pipeline
    pipeline.feed(1)
    assert_raises(RuntimeError) { pipeline.process([2]) }
  end

  def test_double_run_works
    pipeline = two_stage_pipeline
    results = pipeline.process([1, 2])
    assert_equal([4, 6], results)
    results = pipeline.process([1, 2])
    assert_equal([4, 6], results)
    pipeline.feed(2)
    pipeline.feed(3)
    results = pipeline.finish
    assert_equal([6, 8], results)
  end

  def test_no_finish_before_starting
    pipeline = two_stage_pipeline
    assert_raises(RuntimeError) { pipeline.finish }
  end

  def test_discard_results
    pipeline = two_stage_pipeline(discard_results: true)
    results = pipeline.process([1, 2])
    assert_nil(results)
  end

  def test_process_unthreaded
    pipeline = two_stage_pipeline
    results = pipeline.process_unthreaded([1, 2])
    assert_equal([4, 6], results)
  end
end
