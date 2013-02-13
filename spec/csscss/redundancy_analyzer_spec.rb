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
        dec("display", "none") => [sel(%w(h1 h2)), sel(".foo"), sel(".baz")],
        dec("position", "relative") => [sel(%w(h1 h2)), sel(".bar")],
        dec("width", "1px") => [sel(".foo"), sel(".bar")]
      }

      RedundancyAnalyzer.new(css).redundancies(3).should == {
        dec("display", "none") => [sel(%w(h1 h2)), sel(".foo"), sel(".baz")]
      }
    end

    it "finds ignores case with rule_sets" do
      css = %$
        .foo { WIDTH: 1px }
        .bar { width: 1px }
      $

      RedundancyAnalyzer.new(css).redundancies.should == {
        dec("width", "1px") => [sel(".foo"), sel(".bar")]
      }
    end
  end
end
