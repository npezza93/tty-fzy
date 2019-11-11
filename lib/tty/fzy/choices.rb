# frozen_string_literal: true

require_relative "choice"

module TTY
  class Fzy
    class Choices
      include Printable
      extend Forwardable

      attr_accessor :choices, :position

      def_delegator :choices, :size

      def initialize(choices, search)
        @search = search
        @choices = choices.map do |choice|
          Choice.new(search, choice)
        end

        @position = 0

        reset_position!
      end

      def current
        filtered_choices[position]
      end

      def next
        change_current do
          self.position = (position + 1) % filtered_choices.size
        end
      end

      def previous
        change_current do
          self.position = (position - 1) % filtered_choices.size
        end
      end

      def reset_position!
        change_current do
          self.position = 0
        end
      end

      def render
        puts

        print render_choices

        print TTY::Cursor.up(filtered_choices.size)
        print TTY::Cursor.column(0)
      end

      private

      attr_reader :search

      def filtered_choices
        if search.empty?
          choices
        else
          choices.select(&:match?).sort_by { |match| -match.score }
        end.take(::TTY::Fzy.config.lines)
      end

      def render_choices
        max_width = filtered_choices.map(&:width).max
        filtered_choices.map { |choice| choice.render(max_width) }.join("\n")
      end

      def change_current
        choices.map(&:deactivate!)
        yield
        current&.activate!
      end
    end
  end
end
