module Csscss
  module Parser
    module Margin
      extend Parser::Base

      class Parser < Parslet::Parser
        include Common

        rule(:margin_side) {
          length | percent | symbol_list(%w(inherit auto))
        }

        rule(:margin) {
          (
           symbol("inherit") >> eof | (
             margin_side.maybe.as(:top)    >>
             margin_side.maybe.as(:right)  >>
             margin_side.maybe.as(:bottom) >>
             margin_side.maybe.as(:left)
           )
          ).as(:margin)
        }
        root(:margin)
      end

      class Transformer < Parslet::Transform
        @property = :margin
        extend MultiSideTransformer
      end
    end
  end
end
