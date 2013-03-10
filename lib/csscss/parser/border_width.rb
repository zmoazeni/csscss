module Csscss
  module Parser
    module BorderWidth
      extend Parser::Base

      class Parser < Parslet::Parser
        include Common

        rule(:border_width_side) {
          symbol_list(%w(thin medium thick inherit)) | length
        }

        rule(:border_width) {
          (
           symbol("inherit") >> eof | (
             border_width_side.maybe.as(:top)    >>
             border_width_side.maybe.as(:right)  >>
             border_width_side.maybe.as(:bottom) >>
             border_width_side.maybe.as(:left)
           )
          ).as(:border_width)
        }

        root(:border_width)
      end

      class Transformer < Parslet::Transform
        @property = :border_width
        extend MultiSideTransformer

        def self.side_declaration(side, value)
          Declaration.from_parser("border-#{side}-width", value)
        end
      end
    end
  end
end
