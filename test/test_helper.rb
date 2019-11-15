# frozen_string_literal: true

if ENV["COV"]
  require "simplecov"

  SimpleCov.start do
    add_filter "/test/"
  end
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "tty/fzy"
require "pry"

require "minitest/autorun"
require "minitest/pride"
require "ttytest"
