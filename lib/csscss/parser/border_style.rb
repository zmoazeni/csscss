module Csscss
  module Parser
    module BorderStyle
      extend Parser::Base

      class Parser < Parslet::Parser
        include Common

        rule(:border_style_side) {
          symbol_list(%w(none hidden dotted dashed solid
                         double groove ridge inset outset
                      ))
        }

        rule(:border_style) {
          (
           symbol("inherit") >> eof | (
             border_style_side.maybe.as(:top)    >>
             border_style_side.maybe.as(:right)  >>
             border_style_side.maybe.as(:bottom) >>
             border_style_side.maybe.as(:left)
           )
          ).as(:border_style)
        }

        root(:border_style)
      end

      class Transformer < Parslet::Transform
        @property = :border_style
        extend MultiSideTransformer

        class << self
          def side_declaration(side, value)
            Declaration.from_parser("border-#{side}-style", value)
          end
        end
      end
    end
  end
end
