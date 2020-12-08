# frozen_string_literal: true

require 'bundler/setup'
require 'sqlite-toolkit'
require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use! [
  Minitest::Reporters::SpecReporter.new
]
