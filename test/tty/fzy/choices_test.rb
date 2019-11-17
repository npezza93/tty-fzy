# frozen_string_literal: true

require "test_helper"

module TTY
  class Fzy
    class ChoicesTest < Minitest::Test
      extend Forwardable

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

      def_delegators :"TTY::Cursor", :next_line, :clear_screen_down,
                     :save, :restore

      attr_reader :output

      def setup
        @output = StringIO.new

        TTY::Fzy.configure do |config|
          config.output = @output
        end
        stub_winsize
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

        expected = initial_draw_output do
          choices.choices.map.with_index do |choice, idx|
            choice.render(idx.zero?, 40)
          end.join("\n")
        end

        assert_equal expected, raw_output
      end

      def test_filter_with_query
        choices("a").filter

        expected = initial_draw_output do
          choices.choices.first.render(true, 40)
        end

        assert_equal expected, raw_output
      end

      def test_returns
        choices = Choices.new([{ text: "a", returns: "b" }], MockSearch.new, 2)
        assert_equal "b", choices.current.returns

        choices = Choices.new([{ text: "a" }], MockSearch.new, 2)
        assert_equal "a", choices.current.returns
      end

      private

      def initial_draw_output
        save + next_line + clear_screen_down + yield + restore
      end

      def raw_output
        @raw_output ||=
          begin
            output.rewind
            output.read
          end
      end

      def stub_winsize
        TTY::Fzy.config.output.send :define_singleton_method, :winsize do
          [40, 40]
        end
      end

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
