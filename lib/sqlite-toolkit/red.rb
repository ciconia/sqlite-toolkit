# frozen_string_literal: true

require 'sqlite-toolkit/database'

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
        "insert into red_map (key, value) values(?, ?) on conflict(key) do update set value = excluded.value, expire_stamp = null",
        [key, value.to_s]
      )
    end

    def get(key)
      get_first_value("select value from red_map where key = ?", [key])
    end

    def del(key)
      query("delete from red_map where key = ?", [key])
    end

    def exists?(key)
      get_first_value("select 1 from red_map where key = ?", [key]) == 1
    end

    def keys
      query("select key from red_map").map { |r| r['key'] }
    end
  end
end