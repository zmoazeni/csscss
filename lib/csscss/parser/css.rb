module Csscss
  module Parser
    # This is heavily based on the haskell css parser on
    # https://github.com/yesodweb/css-text/blob/add139487c38b68845246449d01c13dbcebac39d/Text/CSS/Parse.hs
    module Css
      class Parser < Parslet::Parser
        include Common

        #def comment(&block)
          #between("/*", "*/", &block)
        #end


        rule(:asterisk) { match('\*') }


        rule(:end_comment) {
          match['^\*'].repeat >> asterisk >> (match("/") | end_comment)
        }

        rule(:comment) {
          (space? >> match('/') >> asterisk >> end_comment >> space?) | space?
        }

        rule(:css_space?) {
          comment | space?
        }

        rule(:attribute) {
          css_space? >>
          match["^:{}"].repeat(1).as(:property) >>
          match(":") >>
          css_space? >>
          match["^;}"].repeat(1).as(:value)
        }

        rule(:attributes) {
          attribute >>
          match(";").maybe >>
          css_space?
        }

        rule(:block) {
          (
            css_space? >>
            match["^{"].repeat(1).as(:selector) >>
            match("{") >>
            attributes.repeat(0).as(:properties) >>
            css_space? >>
            match("}") >>
            css_space?
          ).as(:block)
        }

        rule(:blocks) { block.repeat(0) }
        root(:blocks)
      end

      class Transformer < Parslet::Transform
        rule(block: {
          selector: simple(:selector),
          properties: sequence(:properties)
        }) {
          Ruleset.new(Selector.from_parser(selector), properties)
        }

        rule({
          property: simple(:property),
          value: simple(:value)
        }) {
          Declaration.from_parser(property, value)
        }
      end
    end
  end
end
