module Csscss
  module Parser
    module Base
      def parse(inputs)
        input = Array(inputs).join(" ")

        if parsed = self::Parser.new.try_parse(input)
          self::Transformer.new.apply(parsed)
        end
      end
    end
  end
end
