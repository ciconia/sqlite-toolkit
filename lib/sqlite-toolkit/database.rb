# frozen_string_literal: true

require 'sqlite3'

module SQLiteToolkit
  class Database < SQLite3::Database
    def initialize(*args)
      super
      execute('PRAGMA journal_mode=WAL;')
      execute('PRAGMA synchronous=1;')
      self.busy_timeout = 1000
      self.results_as_hash = true
    end

    def literal(value)
      case value
      when String
        "'#{SQLite3::Database.quote(value)}'"
      when Symbol
        "'#{SQLite3::Database.quote(value.to_s)}'"
      when true
        '1'
      when false
        '0'
      when nil
        'null'
      else
        value.to_s
      end
    end
  end
end
