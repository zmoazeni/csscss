require "test_helper"

module Csscss
  describe RedundancyAnalyzer do
    it "finds and trims redundant rule_sets" do
      css = %$
        h1, h2 { display: none; position: relative; outline:none}
        .foo { display: none; width: 1px }
        .bar { position: relative; width: 1px; outline: none }
        .baz { display: none }
      $

      RedundancyAnalyzer.new(css).redundancies.must_equal({
        [sel(%w(h1 h2)), sel(".bar")] => [dec("position", "relative"), dec("outline", "none")],
        [sel(%w(h1 h2)), sel(".foo"), sel(".baz")] => [dec("display", "none")],
        [sel(".foo"), sel(".bar")] => [dec("width", "1px")]
      })

      RedundancyAnalyzer.new(css).redundancies.first.must_equal [
        [sel(%w(h1 h2)), sel(".bar")], [dec("position", "relative"), dec("outline", "none")]
      ]

      RedundancyAnalyzer.new(css).redundancies(2).must_equal({
        [sel(%w(h1 h2)), sel(".bar")] => [dec("position", "relative"),dec("outline", "none")]
      })
    end

    it "finds ignores case with rule_sets" do
      css = %$
        .foo { WIDTH: 1px }
        .bar { width: 1px }
      $

      RedundancyAnalyzer.new(css).redundancies.must_equal({
        [sel(".foo"), sel(".bar")] => [dec("width", "1px")]
      })
    end
  end
end
