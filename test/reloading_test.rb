require File.dirname(__FILE__) + '/test_helper'

class ReloadingTest < Test::Unit::TestCase
  def test_rewatching_reloaded_module
    BenchmarkForRails.watch('reloading', Some::Klass, :hello)
    original_oid = Some::Klass.object_id
    assert Dependencies.will_unload?(Some::Klass)
    assert Some::Klass.instance_methods.include?('hello_with_benchmark_for_rails')

    Dependencies.clear
    assert_not_equal original_oid, Some::Klass.object_id
    assert Some::Klass.instance_methods.include?('hello_with_benchmark_for_rails')
  end
end