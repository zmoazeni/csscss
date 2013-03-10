module Csscss
  module Parser
    module Padding
      extend Parser::Base

      class Parser < Parslet::Parser
        include Common

        rule(:padding_side) {
          length | percent | symbol("inherit")
        }

        rule(:padding) {
          (
           symbol("inherit") >> eof | (
             padding_side.maybe.as(:top)    >>
             padding_side.maybe.as(:right)  >>
             padding_side.maybe.as(:bottom) >>
             padding_side.maybe.as(:left)
           )
          ).as(:padding)
        }
        root(:padding)
      end

      class Transformer < Parslet::Transform
        @property = :padding
        extend MultiSideTransformer
      end
    end
  end
end
