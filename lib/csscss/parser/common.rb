module Csscss
  module Parser
    module Common
      include Parslet

      UNITS = %w(px em ex in cm mm pt pc)

      rule(:space)   { match["\s"].repeat(1) }
      rule(:space?)  { space.maybe }
      rule(:number)  { match["0-9"] }
      rule(:numbers) { number.repeat(1) }
      rule(:decimal) { numbers >> str(".").maybe >> numbers.maybe }
      rule(:percent) { decimal >> stri("%") >> space? }
      rule(:length)  { decimal >> stri_list(UNITS) >> space?  }
      rule(:inherit) { stri("inherit") }
      rule(:eof)     { any.absent? }

      rule(:http) {
        (match['a-zA-Z.:/'] | str('\(') | str('\)')).repeat >> space?
      }

      rule(:url) {
        (stri("url") >> parens do
          (double_quoted { http } >> space?) |
          (single_quoted { http } >> space?) |
          http
        end).as(:url)
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

      def stri_list(list)
        list.map {|u| stri(u) }.reduce(:|)
      end

      def symbol_list(list)
        list.map {|u| symbol(u) }.reduce(:|)
      end
    end
  end
end
