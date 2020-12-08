# frozen_string_literal: true

require_relative 'helper'

class KeyValueTest < Minitest::Test
  def setup
    @db = SQLiteToolkit::RedDatabase.new('')
  end

  def teardown
  end

  def test_get_set
    assert_nil @db.get('foo')
    
    @db.set('foo', 42)
    assert_equal '42', @db.get('foo')
    assert_nil @db.get('bar')
    
    @db.set('bar', 43)
    assert_equal '42', @db.get('foo')
    assert_equal '43', @db.get('bar')

    @db.set('foo', 44)
    assert_equal '44', @db.get('foo')
    assert_equal '43', @db.get('bar')
  end

  def test_exists_del
    assert_equal false, @db.exists?('foo')
    assert_equal false, @db.exists?('bar')

    @db.set('foo', 42)
    assert_equal true, @db.exists?('foo')
    assert_equal false, @db.exists?('bar')

    @db.set('bar', 43)
    assert_equal true, @db.exists?('foo')
    assert_equal true, @db.exists?('bar')

    @db.del('foo')
    assert_equal false, @db.exists?('foo')
    assert_nil @db.get('foo')
    assert_equal true, @db.exists?('bar')
    assert_equal '43', @db.get('bar')
  end

  def test_keys
    assert_equal [], @db.keys

    @db.set('foo', 42)
    assert_equal ['foo'], @db.keys

    @db.set('bar', 42)
    assert_equal ['bar', 'foo'], @db.keys.sort

    @db.del('foo')
    assert_equal ['bar'], @db.keys

    @db.del('baz')
    assert_equal ['bar'], @db.keys

    @db.del('bar')
    assert_equal [], @db.keys
  end
end
