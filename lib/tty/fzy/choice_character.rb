# frozen_string_literal: true

module TTY
  class Fzy
    class ChoiceCharacter
      def initialize(character, decorations)
        @character  = character
        @foreground = decorations[:foreground]
        @background = decorations[:background]
        @styles     = decorations[:style]
      end

      def to_s(inverse: false, highlight: false)
        @to_s ||= {}
        @to_s[[inverse, highlight]] ||=
          pastel.decorate(character, *styles(inverse, highlight))
      end

      private

      attr_reader :character, :style

      def styles(inverse, highlight)
        [
          background, style, foreground(highlight), (:inverse if inverse)
        ].compact
      end

      def background
        return if @background.nil?

        "on_#{@background}".to_sym
      end

      def foreground(highlight)
        if highlight
          :yellow
        else
          @foreground
        end
      end

      def pastel
        @pastel ||= Pastel.new
      end
    end
  end
end
