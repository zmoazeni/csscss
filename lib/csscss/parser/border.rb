module Csscss
  module Parser
    module Border
      extend Parser::Base

      class Parser < Parslet::Parser
        include Color

        rule(:border_side) { BorderSide::Parser.new(:top).border_side_anonymous }

        rule(:border) {
          (
           symbol("inherit") >> eof |
           border_side.maybe.as(:side)
          ).as(:border)
        }

        root(:border)
      end

      class Transformer < Parslet::Transform
        extend Color::Transformer
        extend Color::PlainColorValue
        extend BorderSide::Transformer::Helpers

        rule(border: simple(:inherit)) {[]}
        rule(border: {
          side: {
            width:simple(:width),
            style:simple(:style),
            color:simple(:color)
          }
        }) {|context|
          [].tap do |declarations|
            [:top, :right, :bottom, :left].each do |side|
              declarations << transform_side(side, context)
            end

            declarations.flatten!
          end
        }
      end
    end
  end
end
