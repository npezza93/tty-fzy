# frozen_string_literal: true

require_relative "choice"

module TTY
  class Fzy
    class Choices
      include Interfaceable
      extend Forwardable

      attr_accessor :choices, :selected

      def initialize(choices, search, max_choices)
        @choices = choices.map { |choice| Choice.new(search, choice) }
        @search = search
        @max_choices = max_choices

        @selected = 0
        @filtered_choices = {}
      end

      def current
        filtered_choices[selected]
      end

      def next
        move_selected(1) do
          if scroll_choices? || selected == filtered_choices.size
            reset_selected
          else
            swap_active(selected - 1)
          end
        end
      end

      def previous
        move_selected(-1) do
          if scroll_choices? || selected.negative?
            reset_selected
          else
            swap_active(selected + 1)
          end
        end
      end

      def filter
        preserve_cursor do
          self.selected = 0
          redraw
        end
      end

      private

      attr_reader :search, :max_choices

      def filtered_choices
        @filtered_choices[search.query] ||=
          if search.empty?
            choices
          else
            choices.select(&:match?).sort_by(&:score).reverse
          end
      end

      def filtered_choices?
        !filtered_choices.empty?
      end

      def scroll_choices?
        (selected + 1 >= max_choices) &&
            selected != (filtered_choices.size - 1)
      end

      def starting_position
        return 0 if selected_offset < max_choices

        if selected_offset + 1 >= filtered_choices.size && filtered_choices?
          filtered_choices.size
        else
          selected_offset + 1
        end - max_choices
      end

      def selected_offset
        selected + TTY::Fzy.config.scroll_offset
      end

      def displayed_choices
        filtered_choices[starting_position, max_choices]
      end

      def wipe_choices
        next_line
        clear_screen_down
      end

      def move_selected(direction)
        return if filtered_choices.empty?

        preserve_cursor do
          self.selected += direction
          yield
        end
      end

      def reset_selected
        if selected == filtered_choices.size
          self.selected = 0
        elsif selected.negative?
          self.selected = filtered_choices.size - 1
        end

        redraw
      end

      def redraw
        wipe_choices
        # max_width = filtered_choices.map(&:width).max
        displayed_choices.map.with_index do |choice, idx|
          choice.render((idx + starting_position) == selected)
        end.tap(&method(:print))
      end

      def swap_active(previous_index)
        previous = filtered_choices[previous_index]
        down(displayed_choices.index(previous) + 1)
        print(previous.render(false), clear: true)

        previous_index > selected ? up : down
        print(current.render(true), clear: true)
      end
    end
  end
end
