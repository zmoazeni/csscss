module Csscss
  module Parser
    module Background
      class Parser < Parslet::Parser
        include Color

        rule(:bg_color)  { color | symbol("inherit") }
        rule(:bg_image)  { url | (symbol("none") | symbol("inherit")).as(:image_literal) }
        rule(:bg_repeat) { symbol_list(%w(repeat-x repeat-y repeat no-repeat inherit)).as(:repeat) }
        rule(:bg_attachment) { symbol_list(%w(scroll fixed inherit)).as(:attachment) }

        rule(:background) {
          (
           bg_color.maybe.as(:bg_color)           >>
           bg_image.maybe.as(:bg_image)           >>
           bg_repeat.maybe.as(:bg_repeat)         >>
           bg_attachment.maybe.as(:bg_attachment)
          ).as(:background)
        }
        root(:background)
      end

      class Transformer < Parslet::Transform
        BG_COLOR = proc {"background-color: #{value}".downcase.strip }
        rule(color:{rgb:simple(:value)}, &BG_COLOR)
        rule(color:{keyword:simple(:value)}, &BG_COLOR)
        rule(color:{hexcolor:simple(:value)}, &BG_COLOR)

        BG_IMG = proc {"background-image: #{value}".downcase.strip }
        rule(image_literal:simple(:value), &BG_IMG)
        rule(url:simple(:value), &BG_IMG)

        rule(:repeat => simple(:repeat)) {
          "background-repeat: #{repeat}".downcase.strip
        }

        rule(:attachment => simple(:attachment)) {
          "background-attachment: #{attachment}".downcase.strip
        }

        rule(background: {
          bg_color:simple(:color),
          bg_image:simple(:url),
          bg_repeat:simple(:repeat),
          bg_attachment:simple(:attachment)
        }) {
          [color, url, repeat, attachment].compact
        }
      end
    end
  end
end
