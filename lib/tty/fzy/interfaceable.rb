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
    end
  end
end
