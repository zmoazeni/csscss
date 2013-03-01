require "test_helper"

module Csscss
  describe RedundancyAnalyzer do
    it "finds and trims redundant rule_sets" do
      css = %$
        h1, h2 { display: none; position: relative; outline:none}
        .foo { display: none; width: 1px }
        .bar { position: relative; width: 1px }
        .baz { display: none }
      $

      RedundancyAnalyzer.new(css).redundancies.must_equal({
        sel(%w(h1 h2)) => {
          dec("display", "none") => [sel(".foo"), sel(".baz")],
          dec("position", "relative") => [sel(".bar")]
        },
        sel(".foo") => { dec("width", "1px") => [sel(".bar")] },
      })

      RedundancyAnalyzer.new(css).redundancies(3).must_equal({
        sel(%w(h1 h2)) => {
          dec("display", "none") => [sel(".foo"), sel(".baz")]
        }
      })
    end

    it "finds ignores case with rule_sets" do
      css = %$
        .foo { WIDTH: 1px }
        .bar { width: 1px }
      $

      RedundancyAnalyzer.new(css).redundancies.must_equal({
        sel(".foo") => {
          dec("width", "1px") => [sel(".bar")]
        }
      })
    end
  end
end
