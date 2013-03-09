module Csscss
  module Parser
    module ListStyle
      extend Parser::Base

      class Parser < Parslet::Parser
        include Common

        rule(:type) {
          symbol_list(%w(disc circle square decimal decimal-leading-zero lower-roman upper-roman lower-greek lower-latin upper-latin armenian georgian lower-alpha upper-alpha none inherit)).as(:type)
        }

        rule(:position) { symbol_list(%w(inside outside inherit)).as(:position) }
        rule(:image) { (url | symbol_list(%w(none inherit))).as(:image) }

        rule(:list_style) {
          (
           symbol("inherit") >> eof | (
            type.maybe.as(:list_style_type) >>
            position.maybe.as(:list_style_position) >>
            image.maybe.as(:list_style_image)
           )
          ).as(:list_style)
        }
        root(:list_style)
      end

      class Transformer < Parslet::Transform
        rule(:list_style => simple(:inherit)) {[]}
        rule(type:simple(:type)) { Declaration.from_parser("list-style-type", type) }
        rule(position:simple(:position)) { Declaration.from_parser("list-style-position", position) }
        rule(image:simple(:image)) { Declaration.from_parser("list-style-image", image) }

        rule(list_style: {
          list_style_type:simple(:type),
          list_style_position:simple(:position),
          list_style_image:simple(:image)
        }) {
          [type, position, image].compact
        }
      end
    end
  end
end
