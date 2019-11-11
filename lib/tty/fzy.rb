# frozen_string_literal: true

require "fzy"
require "tty-reader"
require "tty-cursor"
require "pastel"

require_relative "fzy/printable"
require_relative "fzy/configuration"
require_relative "fzy/search"
require_relative "fzy/choices"

module TTY
  class Fzy
    include Printable

    class << self
      def config
        @config ||= Configuration.new
      end

      def configure
        yield(config)
      end
    end

    IGNORED_KEYS = %i(
      tab ctrl_h ctrl_w ctrl_u ctrl_n ctrl_p
      left right up down backspace keydelete keyreturn
    ).freeze

    attr_reader :search, :choices

    def initialize(choices:)
      @search = Search.new
      @choices = Choices.new(choices, search)
    end

    def keypress(event)
      return if event.value.size > 1 || IGNORED_KEYS.include?(event.key.name)

      search.push(event.value)
      choices.reset_position!
    end

    def keyenter(*)
      finish!(code: 0) do
        print choices.current.returns
      end
    end
    alias keyreturn keyenter

    def keybackspace(*)
      search.backspace
      choices.reset_position!
    end
    alias keyctrl_h keybackspace

    def keydelete(*)
      search.delete
      choices.reset_position!
    end

    def keyright(*)
      search.forward
    end

    def keyleft(*)
      search.back
    end

    def keyup(*)
      choices.previous
    end

    def keydown(*)
      choices.next
    end
    alias keyctrl_n keydown

    def keyctrl_u(*)
      search.clear
      choices.reset_position!
    end

    def keyctrl_w(*)
      search.backspace_word
      choices.reset_position!
    end

    def keytab(*)
      search.autocomplete(choices.current)
      choices.reset_position!
    end

    def call
      print(("\n" * choice_line_count) + cursor.up(choice_line_count))

      reader.subscribe(self) do
        loop do
          render
        end
      end
    end

    private

    def cursor
      TTY::Cursor
    end

    def reader
      @reader ||= TTY::Reader.new(
        input: ::TTY::Fzy.config.input, output: ::TTY::Fzy.config.output,
        env: ENV, track_history: false, interrupt: method(:finish!).to_proc
      ).tap do |tty_reader|
        tty_reader.on(:keyescape, &method(:finish!))
      end
    end

    def finish!(*, code: 1)
      print cursor.clear_line
      yield if block_given?

      exit code
    end

    def render
      print cursor.clear_lines(choice_line_count + 1, :down)
      print cursor.up(choice_line_count)

      choices.render
      search.render
      reader.read_keypress
    end

    def choice_line_count
      [::TTY::Fzy.config.lines, choices.size].min
    end
  end
end
