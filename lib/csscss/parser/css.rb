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
          (space? >> str('/*') >> (str('*/').absent? >> any).repeat >> str('*/') >> space?).as(:comment)
        }

        rule(:css_space?) {
          comment.repeat(1) | space?
        }

        rule(:blank_attribute) { str(";") >> space? }

        rule(:attribute) {
          match["^:{}"].repeat(1).as(:property) >>
          str(":") >>
          match["^;}"].repeat(1).as(:value) >>
          str(";").maybe >>
          space?
        }

        rule(:ruleset) {
          (
            match["^{}"].repeat(1).as(:selector) >>
            str("{") >>
            space? >>
            (comment | attribute | blank_attribute).repeat(0).as(:properties) >>
            str("}") >>
            space?
          ).as(:ruleset)
        }

        rule(:nested_ruleset) {
          (
            str("@") >>
            match["^{}"].repeat(1) >>
            str("{") >>
            (comment | ruleset).repeat(0) >>
            str("}") >>
            space?
          ).as(:nested_ruleset)
        }

        rule(:blocks) {
          space? >> (comment | nested_ruleset | ruleset).repeat(1).as(:blocks) >> space?
        }

        root(:blocks)
      end

      class Transformer < Parslet::Transform
        rule(nested_ruleset: sequence(:rulesets)) {
          rulesets
        }

        rule(comment: simple(:comment)) { nil }

        rule(ruleset: {
          selector: simple(:selector),
          properties: sequence(:properties)
        }) {
          Ruleset.new(Selector.from_parser(selector), properties.compact)
        }

        rule({
          property: simple(:property),
          value: simple(:value)
        }) {
          Declaration.from_parser(property, value)
        }

        rule(blocks: subtree(:rulesets)) {|context|
          context[:rulesets].flatten.compact
        }
      end
    end
  end
end
