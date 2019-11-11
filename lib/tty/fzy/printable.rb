# frozen_string_literal: true

module TTY
  class Fzy
    module Printable
      def puts(string = nil)
        ::TTY::Fzy.config.output.puts(string)
      end

      def print(string)
        ::TTY::Fzy.config.output.print(string)
      end
    end
  end
end
