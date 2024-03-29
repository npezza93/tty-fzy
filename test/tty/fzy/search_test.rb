# frozen_string_literal: true

require "test_helper"

module TTY
  class Fzy
    class SearchTest < Minitest::Test
      ChoiceMock = Struct.new(:text) do
        alias returns text
      end

      def test_push
        search.push("a")

        assert_equal ["a"], search.query
      end

      def test_push_in_different_spot
        search.query = %w(a b c d e)
        search.right
        search.right
        assert_equal 2, search.position

        search.push("f")

        assert_equal %w(a b f c d e), search.query
      end

      def test_delete
        search.query = %w(a)
        search.left
        search.delete

        assert_empty search.query
      end

      def test_delete_in_different_spot
        search.query = %w(a b c d e)
        search.right
        search.right

        search.delete

        assert_equal %w(a b d e), search.query
      end

      def test_backspace
        search.query = %w(a)
        search.right
        search.backspace

        assert_empty search.query
      end

      def test_backspace_in_different_spot
        search.query = %w(a b c d e)
        search.right
        search.right

        search.backspace

        assert_equal %w(a c d e), search.query
      end

      def test_clear
        search.push("a")

        search.clear

        assert_empty search.query
      end

      def test_autocomplete
        search.autocomplete(ChoiceMock.new("thing"))

        assert_equal %w(t h i n g), search.query
      end

      def test_backspace_word
        search.autocomplete(ChoiceMock.new("ab cd"))

        search.backspace_word

        assert_equal %w(a b), search.query
      end

      def test_right_when_empty
        search.right

        assert_equal 0, search.position
      end

      def test_right
        search.autocomplete(ChoiceMock.new("ab"))

        search.left
        assert_equal 1, search.position

        search.right
        assert_equal 2, search.position
      end

      def test_left_when_empty
        search.left

        assert_equal 0, search.position
      end

      def test_left
        search.autocomplete(ChoiceMock.new("ab"))

        search.left
        assert_equal 1, search.position
      end

      def test_render
        search.autocomplete(ChoiceMock.new("a"))

        output.rewind
        assert_equal(
          "#{TTY::Cursor.clear_line}❯ a#{TTY::Cursor.column(4)}", output.read
        )
      end

      private

      def search
        @search ||= begin
          TTY::Fzy.configure do |config|
            config.output = StringIO.new
          end
          TTY::Fzy::Search.new
        end
      end

      def output
        TTY::Fzy.config.output
      end
    end
  end
end
