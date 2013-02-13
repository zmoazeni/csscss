require "spec_helper"

module Csscss
  describe RedundancyAnalyzer do
    it "finds and trims redundant rule_sets" do
      css = %$
        h1, h2 { display: none; position: relative; }
        .foo { display: none; width: 1px }
        .bar { position: relative; width: 1px }
        .baz { display: none }
      $

      RedundancyAnalyzer.new(css).redundancies.should == {
        Declaration.new("display", "none") => [Selector.new(%w(h1 h2)), Selector.new(%w(.foo)), Selector.new(%w(.baz))],
        Declaration.new("position", "relative") => [Selector.new(%w(h1 h2)), Selector.new(%w(.bar))],
        Declaration.new("width", "1px") => [Selector.new(%w(.foo)), Selector.new(%w(.bar))]
      }

      RedundancyAnalyzer.new(css).redundancies(3).should == {
        Declaration.new("display", "none") => [Selector.new(%w(h1 h2)), Selector.new(%w(.foo)), Selector.new(%w(.baz))]
      }
    end

    it "finds ignores case with rule_sets" do
      css = %$
        .foo { WIDTH: 1px }
        .bar { width: 1px }
      $

      RedundancyAnalyzer.new(css).redundancies.should == {
        Declaration.new("width", "1px") => [Selector.new(%w(.foo)), Selector.new(%w(.bar))]
      }
    end
  end
end
