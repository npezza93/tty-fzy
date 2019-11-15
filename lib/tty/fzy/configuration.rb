# frozen_string_literal: true

module TTY
  class Fzy
    class Configuration
      attr_accessor :prompt, :lines, :output
      attr_reader :tty, :input

      def initialize
        self.tty = "/dev/tty"
        @prompt = "❯ "
        @lines  = 10
      end

      def tty=(tty_file)
        @output = IO.new(IO.sysopen(tty_file, "w"))
        @input = IO.new(IO.sysopen(tty_file, "r"))
      end

      private

      attr_writer :input
    end
  end
end
