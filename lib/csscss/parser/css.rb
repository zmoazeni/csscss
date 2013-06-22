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

        rule(:raw_comment) {
          space? >> str('/*') >> (str('*/').absent? >> any).repeat >> str('*/') >> space?
        }
        rule(:comment) { raw_comment.as(:comment) }

        rule(:blank_attribute) { str(";") >> space? }

        rule(:attribute_value) { any_quoted { any } | (str('/*').absent? >> match["^;}"]) | raw_comment }

        rule(:attribute) {
          match["^:{}"].repeat(1).as(:property) >>
          str(":") >>
          (
            (stri("data:").absent? >> attribute_value) |
            (stri("data:").present? >> attribute_value.repeat(1) >> str(";") >> attribute_value.repeat(1))
          ).repeat(1).as(:value) >>
          str(";").maybe >>
          space?
        }

        rule(:mixin_attributes) {
          (
            str('/* CSSCSS START MIXIN') >>
            (str('*/').absent? >> any).repeat >>
            str('*/') >>
            (str('/* CSSCSS END MIXIN').absent? >> any).repeat >>
            str('/* CSSCSS END MIXIN') >>
            (str('*/').absent? >> any).repeat >>
            str('*/') >>
            space?
          ).as(:mixin)
        }

        rule(:ruleset) {
          (
            match["^{}"].repeat(1).as(:selector) >>
            str("{") >>
            space? >>
            (
              mixin_attributes |
              comment          |
              attribute        |
              blank_attribute
            ).repeat(0).as(:properties) >>
            str("}") >>
            space?
          ).as(:ruleset)
        }

        rule(:nested_ruleset) {
          (
            str("@") >>
            match["^{}"].repeat(1) >>
            str("{") >>
            space? >>
            (comment | ruleset | nested_ruleset).repeat(1) >>
            str("}") >>
            space?
          ).as(:nested_ruleset)
        }

        rule(:import) {
          (
            stri("@import") >>
            match["^;"].repeat(1) >>
            str(";") >>
            space?
          ).as(:import)
        }

        rule(:blocks) {
          space? >> (
            comment        |
            import         |
            nested_ruleset |
            ruleset
          ).repeat(1).as(:blocks) >> space?
        }

        root(:blocks)
      end

      class Transformer < Parslet::Transform
        rule(nested_ruleset: subtree(:rulesets)) { |context|
          context[:rulesets].flatten
        }

        rule(import: simple(:import)) { [] }
        rule(mixin: simple(:mixin)) { nil }

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
