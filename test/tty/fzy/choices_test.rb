# frozen_string_literal: true

require "test_helper"

module TTY
  class Fzy
    class ChoicesTest < Minitest::Test
      class MockSearch
        attr_accessor :query

        def initialize(query = nil)
          @query = query.to_s.split("")
        end

        def empty?
          query.nil? || query.empty?
        end

        def pretty_query
          query.to_a.join
        end
      end

      attr_reader :output

      def setup
        @output = StringIO.new

        TTY::Fzy.configure do |config|
          config.output = @output
        end
      end

      def teardown
        @output.close
      end

      def test_current
        assert_equal "a", choices.current.text
      end

      def test_next
        choices.next
        assert_equal 1, choices.selected
        choices.next
        assert_equal 2, choices.selected
        choices.next
        assert_equal 0, choices.selected
      end

      def test_previous
        choices.previous
        assert_equal 2, choices.selected
        choices.previous
        assert_equal 1, choices.selected
        choices.previous
        assert_equal 0, choices.selected
      end

      def test_filter
        choices.filter
        output.rewind

        assert_equal(
          "\e7\e[E\e[1G\e[J\e[7ma\e[0m\nb\nc\e8", output.read
        )
      end

      def test_filter_with_query
        choices("a").filter
        output.rewind

        assert_equal(
          "\e7\e[E\e[1G\e[J\e[33;7ma\e[0m\e8", output.read
        )
      end

      def test_returns
        choices = Choices.new([{ text: "a", returns: "b" }], MockSearch.new, 2)
        assert_equal "b", choices.current.returns

        choices = Choices.new([{ text: "a" }], MockSearch.new, 2)
        assert_equal "a", choices.current.returns
      end

      private

      def choices(query = nil)
        @choices ||= Choices.new(
          [{ text: "a" }, { text: "b" }, { text: "c" }],
          MockSearch.new(query),
          3
        )
      end
    end
  end
end
