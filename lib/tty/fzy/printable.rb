# frozen_string_literal: true

module TTY
  class Fzy
    module Printable
      def printo(string)
        print(string, clear: true)
      end

      def print(string, clear: false)
        string = string.join("\n") if string.is_a?(Array)

        ::TTY::Fzy.config.output.print(TTY::Cursor.clear_line) if clear
        ::TTY::Fzy.config.output.print(string)
      end
    end
  end
end
