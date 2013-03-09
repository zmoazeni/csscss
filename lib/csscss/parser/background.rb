module Csscss
  module Parser
    module Background

      def self.parse(inputs)
        input = Array(inputs).join(" ")

        if parsed = Parser.new.try_parse(input)
          Transformer.new.apply(parsed)
        end
      end

      class Parser < Parslet::Parser
        include Color

        rule(:bg_color)  { color | symbol("inherit") }
        rule(:bg_image)  { url | (symbol("none") | symbol("inherit")).as(:image_literal) }
        rule(:bg_repeat) { symbol_list(%w(repeat-x repeat-y repeat no-repeat inherit)).as(:repeat) }
        rule(:bg_attachment) { symbol_list(%w(scroll fixed inherit)).as(:attachment) }

        rule(:bg_position) {
          lcr_symbols = symbol_list(%w(left center right))
          tcb_symbols = symbol_list(%w(top center bottom))

          (symbol("inherit") | (
            lcr = (percent | length | lcr_symbols)
            tcb = (percent | length | tcb_symbols)

            lcr >> tcb | lcr | tcb
          )).as(:position)
        }

        rule(:background) {
          (
           symbol("inherit") >> eof | (
            bg_color.maybe.as(:bg_color)           >>
            bg_image.maybe.as(:bg_image)           >>
            bg_repeat.maybe.as(:bg_repeat)         >>
            bg_attachment.maybe.as(:bg_attachment) >>
            bg_position.maybe.as(:bg_position)
           )
          ).as(:background)
        }
        root(:background)

        def try_parse(input)
          parsed = (root | nada).parse(input)
          parsed[:nada] ? false : parsed
        end
      end

      class Transformer < Parslet::Transform
        BG_COLOR = proc {Declaration.from_parser("background-color", value) }
        rule(color:{rgb:simple(:value)}, &BG_COLOR)
        rule(color:{keyword:simple(:value)}, &BG_COLOR)
        rule(color:{hexcolor:simple(:value)}, &BG_COLOR)

        BG_IMG = proc {Declaration.from_parser("background-image", value) }
        rule(image_literal:simple(:value), &BG_IMG)
        rule(url:simple(:value), &BG_IMG)

        rule(:repeat => simple(:repeat)) {
          Declaration.from_parser("background-repeat", repeat)
        }

        rule(:attachment => simple(:attachment)) {
          Declaration.from_parser("background-attachment", attachment)
        }

        rule(:position => simple(:position)) {
          Declaration.from_parser("background-position", position)
        }

        rule(:background => simple(:inherit)) {[]}

        rule(background: {
          bg_color:simple(:color),
          bg_image:simple(:url),
          bg_repeat:simple(:repeat),
          bg_attachment:simple(:attachment),
          bg_position:simple(:position)
        }) {
          [color, url, repeat, attachment, position].compact
        }
      end
    end
  end
end
