module Csscss
  module Parser
    module Background
      class Parser < Parslet::Parser
        include Color

        rule(:background_color) { color | symbol("inherit") }
        rule(:background_image) { url | (symbol("none") | symbol("inherit")).as(:image_literal) }

        rule(:background) {
          (background_color.maybe.as(:bg_color) >> background_image.maybe.as(:bg_image)).as(:background)
        }
        root(:background)
      end

      class Transformer < Parslet::Transform
        BG_COLOR = proc {"background-color: #{value.to_s.downcase}".strip }
        rule(color:{rgb:simple(:value)}, &BG_COLOR)
        rule(color:{keyword:simple(:value)}, &BG_COLOR)
        rule(color:{hexcolor:simple(:value)}, &BG_COLOR)

        BG_IMG = proc {"background-image: #{value}"}
        rule(image_literal:simple(:value), &BG_IMG)
        rule(url:simple(:value), &BG_IMG)

        rule(background: {
          bg_color:simple(:color),
          bg_image:simple(:url)
        }) {
          [color, url].compact
        }
      end
    end
  end
end
