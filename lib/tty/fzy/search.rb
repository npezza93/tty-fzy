# frozen_string_literal: true

module TTY
  class Fzy
    class Search
      include Interfaceable
      extend Forwardable

      attr_accessor :query
      attr_reader :position

      def_delegator :query, :empty?

      def initialize
        @position = 0
        @query = []
      end

      def pretty_query
        query.join
      end

      def render
        clear_line
        print("#{prompt}#{pretty_query}")
        column(prompt.size + position + 1)
      end

      def push(character)
        query.insert(position, character)
        self.position += 1
      end

      def delete
        return if position == query.size

        query.delete_at(position)

        render
      end

      def backspace
        return if position.zero?

        query.delete_at(position - 1)
        self.position -= 1
      end

      def backspace_word
        backspace until query.empty? || whitespace_character?
        backspace until query.empty? || !whitespace_character?
      end

      def right
        return if position == query.size

        self.position += 1
      end

      def left
        return if position.zero?

        self.position -= 1
      end

      def clear
        self.query = []
        self.position = 0
      end

      def autocomplete(option)
        self.query = option.returns.split("")
        self.position = query.size
      end

      private

      def whitespace_character?
        query[position - 1].match?(/\s/)
      end

      def prompt
        ::TTY::Fzy.config.prompt
      end

      def position=(new_position)
        @position = new_position
        render
      end
    end
  end
end
