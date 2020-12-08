# frozen_string_literal: true

require 'sqlite-toolkit/database'
require 'json'

module SQLiteToolkit
  class RedDatabase < Database
    def initialize(*args)
      super
      setup
    end

    def setup
      query("create table if not exists red_map (key text primary key, value text, expire_stamp double default null)")
    end

    def set(key, value)
      query(
        "insert into red_map (key, value) values(?, ?) on conflict(key) do update set value = excluded.value",
        [key, value.to_s]
      )
    end

    def setex(key, ttl, value)
      stamp = Time.now.to_f + ttl
      query(
        "insert into red_map (key, value, expire_stamp) values(?, ?, ?) on conflict(key) do update set value = excluded.value, expire_stamp = excluded.expire_stamp",
        [key, value.to_s, stamp]
      )
    end

    def get(key)
      get_first_value("select value from red_map where key = ?", [key])
    end

    def del(key)
      query("delete from red_map where key = ?", [key])
    end

    def exists(key)
      get_first_value("select 1 from red_map where key = ?", [key]) == 1
    end

    def keys
      query("select key from red_map").map { |r| r['key'] }
    end

    def delete_expired_keys
      stamp = Time.now.to_f
      query("delete from red_map where expire_stamp <= ?", [stamp])
    end

    def expire(key, ttl)
      stamp = Time.now.to_f + ttl
      query(
        "update red_map set expire_stamp = ? where key = ?",
        [stamp, key]
      )
    end

    def incr(key)
      query(
        "insert into red_map (key, value) values(?, 1) on conflict(key) do update set value = cast(value as int) + 1",
        [key]
      )
    end

    def incrby(key, delta)
      query(
        "insert into red_map (key, value) values(?, ?) on conflict(key) do update set value = cast(value as int) + ?",
        [key, delta, delta]
      )
    end

    def hset(key, hkey, value)
      json = { hkey => value }.to_json
      query("insert into red_map (key, value) values(?, ?) on conflict(key) do update set value = json_patch(value, excluded.value);",
        [key, json]
      )
    end

    def hget(key, hkey)
      get_first_value("select json_extract(value, '$.#{SQLite3::Database.quote(hkey)}') from red_map where key = ?", [key])
    end

    def hgetall(key)
      hash = get_first_value("select value from red_map where key = ?", [key])
      hash ? JSON.parse(hash) : {}
    end

    def hexists(key, hkey)
      hash = get_first_value("select value from red_map where key = ?", [key])
      hash && JSON.parse(hash).has_key?(hkey)
    end

    def hkeys(key)
      hash = get_first_value("select value from red_map where key = ?", [key])
      hash ? JSON.parse(hash).keys : []
    end

    def hvals(key)
      hash = get_first_value("select value from red_map where key = ?", [key])
      hash ? JSON.parse(hash).values : []
    end

    def mapped_hmset(key, hash)
      json = hash.to_json
      query("insert into red_map (key, value) values(?, ?) on conflict(key) do update set value = json_patch(value, excluded.value);",
        [key, json]
      )
    end

    def hmset(key, *args)
      hash = {}
      idx = 0
      while idx < args.size
        hash[args[idx]] = args[idx + 1]
        idx += 2
      end
      mapped_hmset(key, hash)
    end

    def hdel(key, hkey)
      query("update red_map set value = json_remove(value, '$.#{SQLite3::Database.quote(hkey)}') where key = ?", [key])
    end
  end
end