module Csscss
  module Parser
    module Color
      include Parslet
      include Common

      rule(:color) { (hexcolor | rgb | color_keyword).as(:color) }
      rule(:rgb) { (rgb_with(numbers) | rgb_with(percent)).as(:rgb) }
      rule(:hexcolor) { (str("#") >> match["a-fA-F0-9"].repeat(1)).as(:hexcolor) >> space? }
      rule(:color_keyword) {
        colors = %w(inherit black silver gray white maroon
        red purple fuchsia green lime olive
        yellow navy blue teal aqua)
        colors.map {|c| symbol(c) }.reduce(:|).as(:keyword)
      }

      private
        def rgb_with(parser)
          symbol("rgb") >> parens do
            parser >> space? >>
            symbol(",") >>
            parser >> space? >>
            symbol(",") >>
            parser >> space?
          end
        end
    end
  end
end
