# frozen_string_literal: true

module TTY
  class Fzy
    class Configuration
      attr_accessor :output, :input, :prompt, :lines

      def initialize
        @output = $stdout
        @input  = $stdin
        @prompt = "❯ "
        @lines  = 10
      end
    end
  end
end
