module Csscss
  module Parser
    module Font
      extend Parser::Base

      class Parser < Parslet::Parser
        include Common

        rule(:literal_font) {
          symbol_list(%w(caption icon menu message-box
                        small-caption status-bar))
        }

        rule(:font_style) { symbol_list(%w(normal italic oblique)) }
        rule(:font_variant) { symbol_list(%w(normal small-caps)) }
        rule(:font_weight) {
          symbol_list(%w(normal bold bolder lighter 100 200 300 400 500 600 700 800 900))
        }

        rule(:font_size_absolute) {
          symbol_list(%w(xx-small x-small small medium
                         large x-large xx-large))
        }

        rule(:font_size_relative) { symbol_list(%w(larger smaller)) }

        rule(:font_size) {
          font_size_absolute | font_size_relative | length | percent
        }

        rule(:line_height) {
          symbol("/") >> (
            symbol("normal") | (length | percent | numbers) >> space?
          ).as(:line_height_value)
        }

        rule(:font_family) {
          family = identifier | any_quoted { identifier >> (space? >> identifier).repeat }
          family >> (symbol(",") >> font_family).maybe
        }

        rule(:font) {
          (
           symbol("inherit") >> eof | (
             (
               literal_font.maybe.as(:literal_font) |
               font_style.maybe.as(:font_style) >>
               font_variant.maybe.as(:font_variant) >>
               font_weight.maybe.as(:font_weight) >>

               font_size.as(:font_size) >>
               line_height.maybe.as(:line_height) >>
               font_family.as(:font_family)
             )
           )
          ).as(:font)
        }
        root(:font)
      end

      class Transformer < Parslet::Transform
        rule(font: simple(:inherit)) {[]}
        rule(font: {literal_font:simple(:literal)}) {[]}

        rule(line_height_value: simple(:value)) { value }

        rule(font: {
          font_style: simple(:font_style),
          font_variant: simple(:font_variant),
          font_weight: simple(:font_weight),
          font_size: simple(:font_size),
          line_height: simple(:line_height),
          font_family: simple(:font_family)
        }) {|context|
          [].tap do |declarations|
            context.each do |property, value|
              declarations << Declaration.from_parser(property.to_s.gsub("_", "-"), value, property != :font_family) if value
            end
          end
        }

        #rule(outline: {
          #outline_width:simple(:width),
          #outline_style:simple(:style),
          #outline_color:simple(:color)
        #}) {
          #[].tap do |declarations|
            #declarations << Declaration.from_parser("outline-width", width) if width
            #declarations << Declaration.from_parser("outline-style", style) if style
            #declarations << Declaration.from_parser("outline-color", color) if color
          #end
        #}
      end
    end
  end
end
