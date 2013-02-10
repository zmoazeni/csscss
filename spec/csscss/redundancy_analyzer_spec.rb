require "spec_helper"

module Csscss
  describe RedundancyAnalyzer do
    it "finds redundant rule_sets" do
      css = %$
        h1, h2 { display: none; position: relative; }
        .foo { display: none; width: 1px }
        .bar { position: relative; width: 1px }
      $

      RedundancyAnalyzer.new(css).redundancies.should == [
        Match.new(
          RuleSet.new(%w(h1 h2), [
            Declaration.new("display", "none"),
            Declaration.new("position", "relative")
          ]),
          [
            RuleSet.new(%w(.foo), [Declaration.new("display", "none")]),
            RuleSet.new(%w(.bar), [Declaration.new("position", "relative")])
          ]
        ),

        Match.new(
          RuleSet.new(%w(.foo), [
            Declaration.new("display", "none"),
            Declaration.new("width", "1px")
          ]),
          [
            RuleSet.new(%w(.bar), [Declaration.new("width", "1px")])
          ]
        )
      ]
    end

    it "finds ignores case with rule_sets" do
      css = %$
        .foo { WIDTH: 1px }
        .bar { width: 1px }
      $

      RedundancyAnalyzer.new(css).redundancies.should == [
        Match.new(
          RuleSet.new(%w(.foo), [
            Declaration.new("width", "1px")
          ]),
          [
            RuleSet.new(%w(.bar), [Declaration.new("width", "1px")])
          ]
        )
      ]
    end
  end
end
