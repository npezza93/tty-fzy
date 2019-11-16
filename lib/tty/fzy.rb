# frozen_string_literal: true

require "fzy"
require "tty-reader"
require "tty-cursor"
require "pastel"

require_relative "fzy/printable"
require_relative "fzy/interfaceable"
require_relative "fzy/configurable"
require_relative "fzy/configuration"
require_relative "fzy/search"
require_relative "fzy/choices"

module TTY
  class Fzy
    include Interfaceable
    extend Configurable

    IGNORED_KEYS = %i(
      tab ctrl_h ctrl_w ctrl_u ctrl_n ctrl_p
      left right up down backspace keydelete keyreturn
    ).freeze

    attr_reader :search, :choices

    def initialize(choices:)
      @search = Search.new
      @max_choices = [::TTY::Fzy.config.lines, choices.size, lines - 1].min
      @choices = Choices.new(choices, search, max_choices)
    end

    def keypress(event)
      return if event.value.size > 1 || IGNORED_KEYS.include?(event.key.name)

      search.push(event.value)
      choices.filter
    end

    def keybackspace(*)
      search.backspace
      choices.filter
    end
    alias keyctrl_h keybackspace

    def keydelete(*)
      search.delete
      choices.filter
    end

    def keyctrl_u(*)
      search.clear
      choices.filter
    end

    def keyctrl_w(*)
      search.backspace_word
      choices.filter
    end

    def keytab(*)
      search.autocomplete(choices.current)
      choices.filter
    end

    def keyright(*)
      search.right
    end

    def keyleft(*)
      search.left
    end

    def keyup(*)
      choices.previous
    end

    def keydown(*)
      choices.next
    end
    alias keyctrl_n keydown

    def keyenter(*)
      reader.unsubscribe(self)
      clear_line
      at_exit do
        $stdout.print choices.current.returns
      end
      exit 0
    end
    alias keyreturn keyenter

    def keyescape(*)
      reader.unsubscribe(self)
      clear_line
      exit 1
    end

    def call
      move_screen_up max_choices

      reader.subscribe(self)
      choices.filter
      search.render
      loop(&reader.method(:read_keypress))
    end

    private

    attr_reader :max_choices

    def reader
      @reader ||= TTY::Reader.new(
        input: ::TTY::Fzy.config.input, output: ::TTY::Fzy.config.output,
        env: ENV, track_history: false,
        interrupt: method(:keyescape).to_proc
      )
    end
  end
end
