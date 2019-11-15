# frozen_string_literal: true

require_relative "choice_character"

module TTY
  class Fzy
    class Choice
      extend Forwardable

      attr_accessor :active
      attr_reader :search, :text, :alt

      def_delegators :match, :positions, :score

      def initialize(search, content)
        @search = search

        extract_content(content)
      end

      alias active? active

      def activate!
        self.active = true
      end

      def deactivate!
        self.active = false
      end

      def match?
        search.empty? || !match.nil?
      end

      def render(text_width)
        characters.map.with_index do |character, index|
          character.to_s(inverse: active?, highlight: positions.include?(index))
        end.join + render_alt(text_width).to_s
      end

      def width
        text.size
      end

      def returns
        @returns || raw_text
      end

      private

      def characters
        @characters ||= pastel.undecorate(text).flat_map do |decoration|
          decoration[:text].split("").map do |character|
            ChoiceCharacter.new(character, decoration)
          end
        end
      end

      def render_alt(text_width)
        return if alt.nil?

        (" " * (text_width - text.size)) + "  " + pastel.dim("(#{alt})")
      end

      def match
        @matches ||= {}

        if @matches.key?(search.query)
          @matches[search.query]
        else
          @matches[search.query] = ::Fzy.match(search.pretty_query, raw_text)
        end
      end

      def raw_text
        @raw_text ||= pastel.strip(text)
      end

      def pastel
        @pastel ||= Pastel.new
      end

      def extract_content(content)
        if content.is_a?(Hash)
          @text, @alt, @returns = content.values_at(:text, :alt, :returns)
        else
          @text = content
        end
      end
    end
  end
end
