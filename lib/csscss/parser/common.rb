module Csscss
  module Parser
    module Common
      include Parslet

      UNITS = %w(px em ex in cm mm pt pc)

      rule(:space)           { match['\s'].repeat(1) }
      rule(:space?)          { space.maybe }
      rule(:number)          { match["0-9"] }
      rule(:numbers)         { number.repeat(1) }
      rule(:decimal)         { numbers >> str(".").maybe >> numbers.maybe }
      rule(:percent)         { decimal >> stri("%") >> space? }
      rule(:non_zero_length) { decimal >> stri_list(UNITS) >> space?  }
      rule(:zero_length)     { match["0"] }
      rule(:length)          { zero_length | non_zero_length }
      rule(:identifier)      { match["a-zA-Z"].repeat(1) }
      rule(:inherit)         { stri("inherit") }
      rule(:eof)             { any.absent? }
      rule(:nada)            { any.repeat.as(:nada) }

      rule(:http) {
        (match['a-zA-Z0-9.:/\-'] | str('\(') | str('\)')).repeat >> space?
      }

      rule(:data) {
        stri("data:") >> match['a-zA-Z0-9.:/+;,=\-'].repeat >> space?
      }

      rule(:url) {
        stri("url") >> parens do
          (any_quoted { http } >> space?) |
          (any_quoted { data } >> space?) |
          data | http
        end
      }

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
          stri(s).as(label) >> space?
        else
          stri(s) >> space?
        end
      end

      def between(left, right)
        raise "block not given" unless block_given?
        symbol(left) >> yield >> symbol(right)
      end

      def parens(&block)
        between("(", ")", &block)
      end

      def double_quoted(&block)
        between('"', '"', &block)
      end

      def single_quoted(&block)
        between("'", "'", &block)
      end

      def any_quoted(&block)
        double_quoted(&block) | single_quoted(&block)
      end

      def stri_list(list)
        list.map {|u| stri(u) }.reduce(:|)
      end

      def symbol_list(list)
        list.map {|u| symbol(u) }.reduce(:|)
      end

      def try_parse(input)
        parsed = (root | nada).parse(input)
        parsed[:nada] ? false : parsed
      end
    end
  end
end
