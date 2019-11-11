# frozen_string_literal: true

require "test_helper"

require "tty/fzy/version"

module TTY
  class FzyTest < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil ::TTY::Fzy::VERSION
    end
  end
end
