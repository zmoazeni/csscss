module Csscss
  module Parser
    module BorderSide
      class << self
        def parse(property, inputs)
          input = Array(inputs).join(" ")
          side = find_side(property)

          if parsed = self::Parser.new(side).try_parse(input)
            self::Transformer.new.apply(parsed)
          end
        end

        def find_side(property)
          case property
          when "border-top"    then :top
          when "border-right"  then :right
          when "border-bottom" then :bottom
          when "border-left"   then :left
          else raise "Unknown property #{property}"
          end
        end
      end

      class Parser < Parslet::Parser
        include Common

        attr_reader :side
        def initialize(side)
          @side = side.to_sym
        end

        rule(:border_width) { BorderWidth::Parser.new.border_width_side }
        rule(:border_style) { BorderStyle::Parser.new.border_style_side }
        rule(:border_color) { BorderColor::Parser.new.border_color_side }

        rule(:border_side_anonymous) {
          border_width.maybe.as(:width) >>
          border_style.maybe.as(:style) >>
          border_color.maybe.as(:color)
        }

        rule(:border_side) {
          (
           symbol("inherit") >> eof |
           border_side_anonymous.as(side)
          ).as(:border_side)
        }

        root(:border_side)
      end

      class Transformer < Parslet::Transform
        extend Color::Transformer
        extend Color::PlainColorValue

        module Helpers
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
              declarations << Declaration.from_parser("border-#{side}-color", color) if color
            end
          end
        end
        extend Helpers

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
