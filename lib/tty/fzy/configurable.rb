# frozen_string_literal: true

module TTY
  class Fzy
    module Configurable
      def config
        @config ||= Configuration.new
      end

      def configure
        yield(config)
      end
    end
  end
end
