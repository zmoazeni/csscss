module Csscss
  module Parser
    module Common
      include Parslet

      rule(:spaces)  { match["\s"].repeat }
      rule(:number)  { match["0-9"] }
      rule(:numbers) { number.repeat(1) }
      rule(:percent) { numbers >> (str(".") >> numbers).maybe >> symbol("%") }
      rule(:inherit) { stri("inherit") }

      def stri(str)
        key_chars = str.split(//)
        key_chars.
          collect! { |char|
            if char.upcase == char.downcase
              str(char)
            else
              match["#{char.upcase}#{char.downcase}"]
            end
          }.reduce(:>>)
      end

      def symbol(s, label = nil)
        if label
          stri(s).as(label) >> spaces
        else
          stri(s) >> spaces
        end
      end

      def between(left, right)
        raise "block not given" unless block_given?
        symbol(left) >> yield >> symbol(right)
      end

      def parens(&block)
        between("(", ")", &block)
      end
    end
  end
end
