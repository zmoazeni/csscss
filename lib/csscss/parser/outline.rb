module Csscss
  module Parser
    module Outline
      extend Parser::Base

      class Parser < Parslet::Parser
        include Color

        rule(:outline_width) { BorderWidth::Parser.new.border_width_side }
        rule(:outline_style) { BorderStyle::Parser.new.border_style_side }
        rule(:outline_color) { BorderColor::Parser.new.border_color_side }

        rule(:outline) {
          (
           symbol("inherit") >> eof | (
             outline_width.maybe.as(:outline_width) >>
             outline_style.maybe.as(:outline_style) >>
             outline_color.maybe.as(:outline_color)
           )
          ).as(:outline)
        }
        root(:outline)
      end

      class Transformer < Parslet::Transform
        extend Color::Transformer
        extend Color::PlainColorValue

        rule(outline: simple(:inherit)) {[]}

        rule(outline: {
          outline_width:simple(:width),
          outline_style:simple(:style),
          outline_color:simple(:color)
        }) {
          [].tap do |declarations|
            declarations << Declaration.from_parser("outline-width", width) if width
            declarations << Declaration.from_parser("outline-style", style) if style
            declarations << Declaration.from_parser("outline-color", color) if color
          end
        }
      end
    end
  end
end
