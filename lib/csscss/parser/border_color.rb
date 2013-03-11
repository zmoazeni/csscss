module Csscss
  module Parser
    module BorderColor
      extend Parser::Base

      class Parser < Parslet::Parser
        include Color

        rule(:border_color_side) {
          color | symbol("transparent")
        }

        rule(:border_color) {
          (
           symbol("inherit") >> eof | (
             border_color_side.maybe.as(:top)    >>
             border_color_side.maybe.as(:right)  >>
             border_color_side.maybe.as(:bottom) >>
             border_color_side.maybe.as(:left)
           )
          ).as(:border_color)
        }

        root(:border_color)
      end

      class Transformer < Parslet::Transform
        @property = :border_color
        extend MultiSideTransformer
        extend Color::Transformer
        extend Color::PlainColorValue

        class << self
          def side_declaration(side, value)
            Declaration.from_parser("border-#{side}-color", value)
          end
        end
      end
    end
  end
end
