# frozen_string_literal: true

require_relative 'helper'

class KeyValueTest < Minitest::Test
  def setup
    @db = SQLiteToolkit::RedDatabase.new('')
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
    assert_equal false, @db.exists('foo')
    assert_equal false, @db.exists('bar')

    @db.set('foo', 42)
    assert_equal true, @db.exists('foo')
    assert_equal false, @db.exists('bar')

    @db.set('bar', 43)
    assert_equal true, @db.exists('foo')
    assert_equal true, @db.exists('bar')

    @db.del('foo')
    assert_equal false, @db.exists('foo')
    assert_nil @db.get('foo')
    assert_equal true, @db.exists('bar')
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

  def test_setex
    @db.setex('foo', 0.01, 42)
    assert_equal '42', @db.get('foo')

    sleep 0.005
    @db.delete_expired_keys
    assert_equal '42', @db.get('foo')
    assert_equal ['foo'], @db.keys

    sleep 0.006
    @db.delete_expired_keys
    assert_nil @db.get('foo')
    assert_equal [], @db.keys


    @db.setex('foo', 0.01, 42)
    assert_equal '42', @db.get('foo')

    sleep 0.005
    @db.delete_expired_keys
    assert_equal '42', @db.get('foo')
    assert_equal ['foo'], @db.keys
    
    @db.setex('foo', 0.01, 43)
    assert_equal '43', @db.get('foo')
    assert_equal ['foo'], @db.keys

    sleep 0.005
    @db.delete_expired_keys
    assert_equal '43', @db.get('foo')
    assert_equal ['foo'], @db.keys

    sleep 0.006
    @db.delete_expired_keys
    assert_nil @db.get('foo')
    assert_equal [], @db.keys
  end

  def test_expire
    @db.set('foo', 42)
    @db.expire('foo', 0.01)

    sleep 0.005
    @db.delete_expired_keys
    assert_equal '42', @db.get('foo')
    assert_equal ['foo'], @db.keys

    sleep 0.006
    @db.delete_expired_keys
    assert_nil @db.get('foo')
    assert_equal [], @db.keys
  end

  def test_incr
    @db.incr('foo')
    assert_equal '1', @db.get('foo')
    
    @db.incr('foo')
    assert_equal '2', @db.get('foo')

    @db.del('foo')
    @db.incr('foo')
    assert_equal '1', @db.get('foo')
  end

  def test_incrby
    @db.incrby('foo', 3)
    assert_equal '3', @db.get('foo')
    
    @db.incrby('foo', -42)
    assert_equal '-39', @db.get('foo')

    @db.incrby('foo', 43)
    assert_equal '4', @db.get('foo')
  end
end

class HashTest < Minitest::Test
  def setup
    @db = SQLiteToolkit::RedDatabase.new('')
  end

  def test_hget_hset
    assert_equal false, @db.exists('foo')
    assert_nil @db.hget('foo', 'bar')
    
    @db.hset('foo', 'bar', 'baz')
    assert_equal true, @db.exists('foo')
    assert_equal 'baz', @db.hget('foo', 'bar')

    @db.hset('foo', 'bar-bar', 'baz-baz')
    assert_equal 'baz', @db.hget('foo', 'bar')
    assert_equal 'baz-baz', @db.hget('foo', 'bar-bar')

    @db.hset('foo', 'bar bar', 'baz baz')
    assert_equal 'baz', @db.hget('foo', 'bar')
    assert_equal 'baz-baz', @db.hget('foo', 'bar-bar')
    assert_equal 'baz baz', @db.hget('foo', 'bar bar')
  end

  def test_hgetall
    assert_equal({}, @db.hgetall('foo'))

    @db.hset('foo', 'bar', 'baz')
    assert_equal({ 'bar' => 'baz' }, @db.hgetall('foo'))

    @db.hset('foo', 'bar-bar', 'baz-baz')
    assert_equal({ 'bar' => 'baz', 'bar-bar' => 'baz-baz' }, @db.hgetall('foo'))
  end

  def test_hexists
    assert !@db.hexists('foo', 'bar')

    @db.hset('foo', 'bar', 'baz')
    assert @db.hexists('foo', 'bar')
    assert !@db.hexists('foo', 'baz')
  end

  def test_hkeys
    assert_equal [], @db.hkeys('foo')

    @db.hset('foo', 'bar', 'baz')
    @db.hset('foo', 'bar-bar', 'baz-baz')

    assert_equal ['bar', 'bar-bar'], @db.hkeys('foo')
  end

  def test_hvals
    assert_equal [], @db.hvals('foo')

    @db.hset('foo', 'bar', 'baz')
    @db.hset('foo', 'bar-bar', 'baz-baz')

    assert_equal ['baz', 'baz-baz'], @db.hvals('foo')
  end

  def test_hmset
    @db.hmset('foo', 'bar', 1, 'baz', 2)
    assert_equal({ 'bar' => 1, 'baz' => 2 }, @db.hgetall('foo'))

    @db.mapped_hmset('foo', 'what' => 42, 'why' => 43)
    assert_equal({ 'bar' => 1, 'baz' => 2, 'what' => 42, 'why' => 43 }, @db.hgetall('foo'))
  end

  def test_hdel
    @db.hset('foo', 'bar', 'baz')
    @db.hset('foo', 'bar-bar', 'baz-baz')
    @db.hdel('foo', 'bar')
    assert_equal({ 'bar-bar' => 'baz-baz' }, @db.hgetall('foo'))
  end
end
