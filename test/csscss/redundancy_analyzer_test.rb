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
        [sel(".bar"), sel(%w(h1 h2))] => [dec("outline", "none"), dec("position", "relative")],
        [sel(".bar"), sel(".foo")] => [dec("width", "1px")],
        [sel(".baz"), sel(".foo"), sel(%w(h1 h2))] => [dec("display", "none")]
      })

      RedundancyAnalyzer.new(css).redundancies.first.must_equal [
        [sel(".bar"), sel(%w(h1 h2))] , [dec("outline", "none"), dec("position", "relative")]
      ]

      RedundancyAnalyzer.new(css).redundancies(2).must_equal({
        [sel(".bar"), sel(%w(h1 h2))] => [dec("outline", "none"), dec("position", "relative")]
      })
    end

    it "finds ignores case with rule_sets" do
      css = %$
        .foo { WIDTH: 1px }
        .bar { width: 1px }
      $

      RedundancyAnalyzer.new(css).redundancies.must_equal({
        [sel(".bar"), sel(".foo")] => [dec("width", "1px")]
      })
    end

    it "doesn't return solo selectors" do
      css = %$
        .foo {
          -webkit-border-radius: 4px;
          -moz-border-radius: 4px;
        }
      $
      RedundancyAnalyzer.new(css).redundancies.must_equal({})
    end

    it "correctly finds counts" do
      css = %$
        .foo {
          -webkit-border-radius: 4px;
          -moz-border-radius: 4px;
        }

        .bar {
          background: white;

          -webkit-border-radius: 4px;
          -moz-border-radius: 4px;
          box-shadow: 1px 1px 10px #CCCCCC;
          -moz-box-shadow: 1px 1px 10px #CCCCCC;
          -webkit-box-shadow: 1px 1px 10px #CCCCCC;
        }

        .baz {
          margin: 3px 3px 30px 3px;
          padding: 10px 30px;
          background: white url(images/bg-bolt-inactive.png) no-repeat 99% 5px;

          -webkit-border-radius: 4px;
          -moz-border-radius: 4px;
          box-shadow: 1px 1px 10px #CCCCCC;
          -moz-box-shadow: 1px 1px 10px #CCCCCC;
          -webkit-box-shadow: 1px 1px 10px #CCCCCC;
        }
      $

      redundancies = RedundancyAnalyzer.new(css).redundancies(3)
      redundancies[[sel(".bar"), sel(".baz")]].size.must_equal(5)
    end
  end
end
