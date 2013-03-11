module Csscss
  module Parser
    module BorderSide
      extend Parser::Base

      class Parser < Parslet::Parser
        include Common

        attr_reader :side
        def initialize(side)
          @side = side.to_sym
        end

        rule(:border_width) { BorderWidth::Parser.new.border_width_side }
        rule(:border_style) { BorderStyle::Parser.new.border_style_side }
        rule(:border_color) { BorderColor::Parser.new.border_color_side }

        rule(:border_side) {
          (
           symbol("inherit") >> eof  | (
             border_width.maybe.as(:width) >>
             border_style.maybe.as(:style) >>
             border_color.maybe.as(:color)
            ).as(side)
          ).as(:border_side)
        }

        root(:border_side)
      end

      class Transformer < Parslet::Transform
        extend Color::Transformer

        class << self
          def transform_top(context);    transform_side("top", context);    end
          def transform_right(context);  transform_side("right", context);  end
          def transform_bottom(context); transform_side("bottom", context); end
          def transform_left(context);   transform_side("left", context);   end

          def transform_side(side, context)
            width = context[:width]
            style = context[:style]
            color = context[:color]

            [].tap do |declarations|
              declarations << Declaration.from_parser("border-#{side}-width", width) if width
              declarations << Declaration.from_parser("border-#{side}-style", style) if style
              declarations << Declaration.from_parser("border-#{side}-color", color.value) if color
            end
          end
        end

        rule(border_side: simple(:inherit)) {[]}

        [:top, :right, :bottom, :left].each do |side|
          rule(border_side: {
            side => {
              width:simple(:width),
              style:simple(:style),
              color:simple(:color)
            }
          }, &method("transform_#{side}"))
        end

      end
    end
  end
end
