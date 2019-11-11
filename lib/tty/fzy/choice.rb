# frozen_string_literal: true

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
        text.split("").map.with_index do |character, index|
          pastel.decorate(character, *character_decorations(index))
        end.join + render_alt(text_width).to_s
      end

      def width
        text.size
      end

      def returns
        @returns || text
      end

      private

      def character_decorations(index)
        decorations = []
        decorations.push(:yellow) if match? && positions.include?(index)
        decorations.push(:inverse) if active?

        decorations
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
          @matches[search.query] = ::Fzy.match(search.pretty_query, text)
        end
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
