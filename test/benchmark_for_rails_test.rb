require File.dirname(__FILE__) + '/test_helper'

class BenchmarkForRailsTest < Test::Unit::TestCase

  def setup
    BenchmarkForRails.results.clear
  end

  def test_measure_preserves_return
    assert_equal 'gyro', BenchmarkForRails.measure('deliciousness') { 'gyro' }
  end

  def test_measure_adds_result
    assert_nil BenchmarkForRails.results['sky']
    BenchmarkForRails.measure('sky') { 'wide' }
    assert_not_nil BenchmarkForRails.results['sky']
  end

  def test_measure_adds_to_existing_result
    assert_nil BenchmarkForRails.results['nalgene']
    BenchmarkForRails.measure('nalgene') { 'liter' }
    liter_measurement = BenchmarkForRails.results['nalgene']
    BenchmarkForRails.measure('nalgene') { '750ml' }
    assert BenchmarkForRails.results['nalgene'] > liter_measurement
  end

  def test_basic_accuracy_of_measure
    BenchmarkForRails.measure('somnolence') { sleep 0.2 }
    assert BenchmarkForRails.results['somnolence'] < 0.21
    assert BenchmarkForRails.results['somnolence'] > 0.19
  end

  # a test for measuring recursive functions
  def test_nested_duplicate_measurements
    BenchmarkForRails.measure('recursive') do
      sleep 0.2
      BenchmarkForRails.measure('recursive') do
        sleep 0.2
      end
    end
    assert BenchmarkForRails.results['recursive'] < 0.41
    assert BenchmarkForRails.results['recursive'] > 0.39
  end

  def test_watching_passes_blocks
    BenchmarkForRails.watch('yielding', Some::Klass, :yielder)
    assert_equal 'christmas', Some::Klass.new.yielder { 'christmas' }
  end

  def test_watching_passes_args
    BenchmarkForRails.watch('echoer', Some::Klass, :echoer)
    assert_equal [1, 1, 2, 3, 5], Some::Klass.new.echoer(1, 1, 2, 3, 5)
  end

  def test_watching_instance_method
    BenchmarkForRails.watch('instance_method', Some::Klass, :hello)
    assert_equal 'hello', Some::Klass.new.hello
    assert_not_nil BenchmarkForRails.results['instance_method']
  end

  def test_watching_class_method
    BenchmarkForRails.watch('class_method', Some::Klass, :world, false)
    assert_equal 'world', Some::Klass.world
    assert_not_nil BenchmarkForRails.results['class_method']
  end

  def test_watching_module_method
    BenchmarkForRails.watch('module_method', Some::Module, :foo)
    assert_equal 'foo', Some::Klass.new.foo
    assert_not_nil BenchmarkForRails.results['module_method']
  end

  # it's not called a module class method, is it? oh well.
  def test_watching_module_class_method
    BenchmarkForRails.watch('module_class_method', Some::Module, :bar, false)
    assert_equal 'bar', Some::Module.bar
    assert_not_nil BenchmarkForRails.results['module_class_method']
  end
end
