# frozen_string_literal: true

module TTY
  class Fzy
    class Search
      include Printable
      extend Forwardable

      attr_accessor :position, :query

      def_delegator :query, :empty?

      def initialize
        @position = 0
        @query = []
      end

      def pretty_query
        query.join
      end

      def render
        print("#{::TTY::Fzy.config.prompt}#{pretty_query}")
        print(TTY::Cursor.backward(position)) if position.positive?
      end

      def push(character)
        query.insert(query.size - position, character)
      end

      def delete
        query.delete_at(query.size - position)
        forward
      end

      def backspace
        query.delete_at(query.size - 1 - position)
      end

      def backspace_word
        backspace until query.empty? || whitespace_character?
        backspace until query.empty? || !whitespace_character?
      end

      def forward
        self.position -= 1 unless position.zero?
      end

      def back
        self.position += 1 unless position == query.size
      end

      def clear
        self.query = []
      end

      def autocomplete(option)
        self.query = option.text.split("")
      end

      private

      def whitespace_character?
        query[query.size - 1 - position].match?(/\s/)
      end
    end
  end
end
