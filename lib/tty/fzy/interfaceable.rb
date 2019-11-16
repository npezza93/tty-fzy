# frozen_string_literal: true

module TTY
  class Fzy
    module Interfaceable
      include Printable

      def save
        print TTY::Cursor.save
      end

      def restore
        print TTY::Cursor.restore
      end

      def up(number = nil)
        print TTY::Cursor.up(number)
      end

      def down(number = nil)
        print TTY::Cursor.down(number)
      end

      def forward(number = nil)
        print TTY::Cursor.forward(number)
      end

      def backward(number = nil)
        print TTY::Cursor.backward(number)
      end

      def clear_line
        print TTY::Cursor.clear_line
      end

      def clear_lines(number = nil)
        print TTY::Cursor.clear_lines(number, :down)
      end

      def column(col)
        print TTY::Cursor.column(col)
      end

      def preserve_cursor
        save

        yield

        restore
      end

      def lines
        IO.console.winsize[0]
      end

      def move_screen_up(lines)
        print "\n" * lines
        up lines
      end

      def next_line
        print TTY::Cursor.next_line
      end

      def clear_screen_down
        print TTY::Cursor.clear_screen_down
      end
    end
  end
end
