# frozen_string_literal: true

module TTY
  class Fzy
    class Configuration
      attr_accessor :prompt, :lines, :scroll_offset
      attr_reader :tty
      attr_writer :output

      def initialize
        self.tty = "/dev/tty"
        @prompt = "❯ "
        @lines  = 10
        @scroll_offset = 1
      end

      def tty=(tty_file)
        @tty = tty_file
        @output = nil
        @input = nil
      end

      def input
        @input ||= IO.new(IO.sysopen(tty_file, "r"))
      end

      def output
        @output ||= IO.new(IO.sysopen(tty_file, "w"))
      end

      private

      attr_writer :input
    end
  end
end
