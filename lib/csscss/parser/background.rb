module Csscss
  module Parser
    module Background
      class Parser < Parslet::Parser
        include Color

        #rule(:background_color) { (color | symbol("inherit")).as(:bg_color) }
        #rule(:background_url) { (url | symbol("none") | symbol("inherit")).as(:bg_url) }

        rule(:background_color) { color | symbol("inherit") }
        rule(:background_image) { url | (symbol("none") | symbol("inherit")).as(:image_literal) }

        rule(:background) {
          (background_color.maybe.as(:bg_color) >> background_image.maybe.as(:bg_image)).as(:background)
        }
        root(:background)
      end

      class Transformer < Parslet::Transform
        rule(rgb:{
          red:{percent:simple(:red)},
          green:{percent:simple(:green)},
          blue:{percent:simple(:blue)}
        }) { {rgb:{red:"#{red}%", green:"#{green}%", blue:"#{blue}%"}}}

        rule(color:{rgb:subtree(:rgb)}) {
          "background-color: rgb(#{rgb[:red]}, #{rgb[:green]}, #{rgb[:blue]})"
        }

        rule(color:{keyword:simple(:keyword)}) {
          "background-color: #{keyword.to_s.downcase}".strip
        }

        rule(color:{hexcolor:simple(:value)}) {
          "background-color: ##{value}"
        }

        rule(image_literal:simple(:url)) {"background-image: #{url}"}
        rule(url:simple(:url)) {"background-image: #{url}"}

        rule(background: {
          bg_color:simple(:color),
          bg_image: simple(:url)
        }) {
          [color, url].compact
        }
      end
    end
  end
end
