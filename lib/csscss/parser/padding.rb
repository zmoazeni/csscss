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
        rule(padding: simple(:inherit)) {[]}

        SIDE = proc {|side, value| Declaration.from_parser("padding-#{side}", value) }

        rule(padding: {
          top:simple(:top),
          right:simple(:right),
          bottom:simple(:bottom),
          left:simple(:left)
        }) {
          values = [top, right, bottom, left].compact
          case values.size
          when 4
            %w(top right bottom left).zip(values).map {|side, value| SIDE[side, value] }
          when 3
            %w(top right bottom).zip(values).map {|side, value| SIDE[side, value] }.tap do |declarations|
              declarations << SIDE["left", values[1]]
            end
          when 2
            %w(top right).zip(values).map {|side, value| SIDE[side, value] }.tap do |declarations|
              declarations << SIDE["bottom", values[0]]
              declarations << SIDE["left", values[1]]
            end
          when 1
            %w(top right bottom left).map do |side|
              SIDE[side, values[0]]
            end
          end
        }
      end
    end
  end
end
