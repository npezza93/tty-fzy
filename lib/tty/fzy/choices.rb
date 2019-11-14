# frozen_string_literal: true

require_relative "choice"

module TTY
  class Fzy
    class Choices
      include Interfaceable
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
        return if filtered_choices.empty?

        save
        down(position + 1)
        clear_line
        current.deactivate!
        print current.render(30)
        self.position += 1
        if position > filtered_choices.size - 1
          self.position = 0
          current.activate!
          up(filtered_choices.size - 1)
        else
          current.activate!
          down
        end
        clear_line
        print current.render(30)
        restore
      end

      def previous
        return if filtered_choices.empty?

        save
        down(position + 1)
        clear_line
        current.deactivate!
        print current.render(30)
        self.position -= 1
        if position.negative?
          self.position = filtered_choices.size - 1
          current.activate!
          down(filtered_choices.size - 1)
        else
          current.activate!
          up
        end
        clear_line
        print current.render(30)
        restore
      end

      def reset_position!
        change_current do
          self.position = 0
        end
      end

      def rerender
        reset_position!
        preserve_cursor do
          wipe_screen
          print render_choices
        end
      end

      private

      attr_reader :search

      def filtered_choices
        @filtered_choices ||= {}
        @filtered_choices[search.query] ||=
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

      def preserve_cursor
        save

        yield

        restore
      end

      def wipe_screen
        lines = [::TTY::Fzy.config.lines, choices.size].min
        down
        clear_lines lines
        up lines - 1
      end
    end
  end
end
