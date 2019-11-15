# frozen_string_literal: true

require_relative "choice"

module TTY
  class Fzy
    class Choices
      include Interfaceable
      extend Forwardable

      attr_accessor :choices, :selected

      def initialize(choices, search, max_choices)
        @choices = choices.map do |choice|
          Choice.new(search, choice)
        end
        @search = search
        @max_choices = max_choices

        @selected = 0
      end

      def current
        filtered_choices[selected]
      end

      def next
        return if filtered_choices.empty?

        preserve_cursor do
          down(selected + 1)
          clear_line
          current.deactivate!
          print current.render(30)
          self.selected += 1
          if selected > filtered_choices.size - 1
            self.selected = 0
            current.activate!
            up(filtered_choices.size - 1)
          else
            current.activate!
            down
          end
          clear_line
          print current.render(30)
        end
      end

      def previous
        return if filtered_choices.empty?

        preserve_cursor do
          down(selected + 1)
          clear_line
          current.deactivate!
          print current.render(30)
          self.selected -= 1
          if selected.negative?
            self.selected = filtered_choices.size - 1
            current.activate!
            down(filtered_choices.size - 1)
          else
            current.activate!
            up
          end
          clear_line
          print current.render(30)
        end
      end

      def filter
        reset_selected
        preserve_cursor do
          wipe_screen
          print render_choices
        end
      end

      private

      attr_reader :search, :max_choices

      def filtered_choices
        @filtered_choices ||= {}
        @filtered_choices[search.query] ||=
          if search.empty?
            choices
          else
            choices.select(&:match?).sort_by { |match| -match.score }
          end.take(max_choices)
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

      def wipe_screen
        down
        clear_lines max_choices
        up max_choices - 1
      end

      def reset_selected
        change_current do
          self.selected = 0
        end
      end
    end
  end
end
