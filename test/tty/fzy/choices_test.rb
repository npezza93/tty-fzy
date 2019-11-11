# frozen_string_literal: true

require "test_helper"

module TTY
  class Fzy
    class ChoicesTest < Minitest::Test
      class MockOutput
        def initialize
          @stream = ""
        end

        attr_accessor :stream

        def puts(text = nil)
          self.stream += "#{text}\n"
        end

        def print(text)
          self.stream += text
        end
      end

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
        @output = MockOutput.new

        TTY::Fzy.configure do |config|
          config.output = @output
        end
      end

      def test_current
        assert_equal "a", choices.current.text
      end

      def test_size
        assert_equal 3, choices.size
      end

      def test_next
        choices.next
        assert_equal 1, choices.position
        choices.next
        assert_equal 2, choices.position
        choices.next
        assert_equal 0, choices.position
      end

      def test_previous
        choices.previous
        assert_equal 2, choices.position
        choices.previous
        assert_equal 1, choices.position
        choices.previous
        assert_equal 0, choices.position
      end

      def test_render
        choices.render

        assert_equal "\na\nb\nc\e[3A\e[0G", Pastel.new.strip(output.stream)
      end

      def test_render_with_query
        choices("a").render

        assert_equal "\na\e[1A\e[0G", Pastel.new.strip(output.stream)
      end

      def test_returns
        choices = Choices.new([{ text: "a", returns: "b" }], MockSearch.new)
        assert_equal "b", choices.current.returns

        choices = Choices.new([{ text: "a" }], MockSearch.new)
        assert_equal "a", choices.current.returns
      end

      private

      def choices(query = nil)
        @choices ||= Choices.new(
          [{ text: "a" }, { text: "b" }, { text: "c" }],
          MockSearch.new(query)
        )
      end
    end
  end
end
