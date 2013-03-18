module Csscss
  module Parser
    # This is heavily based on the haskell css parser on
    # https://github.com/yesodweb/css-text/blob/add139487c38b68845246449d01c13dbcebac39d/Text/CSS/Parse.hs
    module Css
      class << self
        def parse(source)
          Transformer.new.apply(Parser.new.parse(source))
        end
      end

      class Parser < Parslet::Parser
        include Common

        rule(:comment) {
          space? >> str('/*') >> (str('*/').absent? >> any).repeat >> str('*/') >> space?
        }

        rule(:css_space?) {
          comment.repeat(1) | space?
        }

        rule(:attribute) {
          css_space? >>
          match["^:{}"].repeat(1).as(:property) >>
          str(":") >>
          css_space? >>
          match["^;}"].repeat(1).as(:value)
        }

        rule(:attributes) {
          attribute >>
          str(";").maybe >>
          css_space?
        }

        rule(:ruleset) {
          (
            css_space? >>
            match["^{}"].repeat(1).as(:selector) >>
            str("{") >>
            attributes.repeat(0).as(:properties) >>
            css_space? >>
            str("}") >>
            css_space?
          ).as(:ruleset)
        }

        rule(:nested_ruleset) {
          css_space? >>
          str("@") >>
          match["^{}"].repeat(1) >>
          str("{") >>
          ruleset.repeat(0) >>
          css_space? >>
          str("}") >>
          css_space?
        }

        rule(:blocks) { (nested_ruleset.as(:nested) | ruleset).repeat(0).as(:blocks) }
        root(:blocks)
      end

      class Transformer < Parslet::Transform
        rule(nested: sequence(:rulesets)) {
          rulesets
        }

        rule(ruleset: {
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

        rule(blocks: subtree(:rulesets)) {
          rulesets.flatten
        }
      end
    end
  end
end
