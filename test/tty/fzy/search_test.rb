# frozen_string_literal: true

require "test_helper"

module TTY
  class Fzy
    class SearchTest < Minitest::Test
      class MockOutput
        def initialize
          @stream = ""
        end

        attr_accessor :stream

        def print(text)
          self.stream += text
        end
      end

      def test_push
        search.push("a")

        assert_equal ["a"], search.query
      end

      def test_push_in_different_spot
        search.query = %w(a b c d e)
        search.position = 3

        search.push("f")

        assert_equal %w(a b f c d e), search.query
      end

      def test_delete
        search.query = %w(a)
        search.position = 1
        search.delete

        assert_empty search.query
      end

      def test_delete_in_different_spot
        search.query = %w(a b c d e)
        search.position = 3

        search.delete

        assert_equal %w(a b d e), search.query
      end

      def test_backspace
        search.query = %w(a)
        search.backspace

        assert_empty search.query
      end

      def test_backspace_in_different_spot
        search.query = %w(a b c d e)
        search.position = 3

        search.backspace

        assert_equal %w(a c d e), search.query
      end

      def test_clear
        search.push("a")

        search.clear

        assert_empty search.query
      end

      def test_autocomplete
        choice = Struct.new(:text)
        search.autocomplete(choice.new("thing"))

        assert_equal %w(t h i n g), search.query
      end

      def test_backspace_word
        choice = Struct.new(:text)
        search.autocomplete(choice.new("ab cd"))

        search.backspace_word

        assert_equal %w(a b), search.query
      end

      def test_forward_when_empty
        search.forward

        assert_equal 0, search.position
      end

      def test_forward
        choice = Struct.new(:text)
        search.autocomplete(choice.new("ab"))
        search.position = 1

        search.forward

        assert_equal 0, search.position
      end

      def test_back_when_empty
        search.back

        assert_equal 0, search.position
      end

      def test_back
        choice = Struct.new(:text)
        search.autocomplete(choice.new("ab"))
        search.position = 1

        search.back

        assert_equal 2, search.position
      end

      def test_render
        choice = Struct.new(:text)
        search.autocomplete(choice.new("a"))
        search.render

        assert_equal "❯ a", TTY::Fzy.config.output.stream
      end

      private

      def search
        @search ||= begin
          TTY::Fzy.configure do |config|
            config.output = MockOutput.new
          end
          TTY::Fzy::Search.new
        end
      end
    end
  end
end
