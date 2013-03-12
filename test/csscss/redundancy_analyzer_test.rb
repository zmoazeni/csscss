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

    it "also matches shorthand rules" do
      css = %$
        .foo { background-color: #fff }
        .bar { background: #fff top }
      $

      RedundancyAnalyzer.new(css).redundancies.must_equal({
        [sel(".bar"), sel(".foo")] => [dec("background-color", "#fff")]
      })
    end

    it "keeps full shorthand together" do
      css = %$
        .baz { background-color: #fff }
        .foo { background: #fff top }
        .bar { background: #fff top }
      $

      RedundancyAnalyzer.new(css).redundancies.must_equal({
        [sel(".bar"), sel(".foo")] => [dec("background", "#fff top")],
        [sel(".bar"), sel(".baz"), sel(".foo")] => [dec("background-color", "#fff")]
      })
    end

    it "doesn't consolidate explicit short/longhand" do
      css = %$
        .foo { background-color: #fff }
        .bar { background: #fff }
      $

      RedundancyAnalyzer.new(css).redundancies.must_equal({
        [sel(".bar"), sel(".foo")] => [dec("background-color", "#fff")]
      })

      css = %$
        .bar { background: #fff }
        .foo { background-color: #fff }
      $

      RedundancyAnalyzer.new(css).redundancies.must_equal({
        [sel(".bar"), sel(".foo")] => [dec("background-color", "#fff")]
      })
    end

    it "3-way case consolidation" do
      css = %$
        .bar { background: #fff }
        .baz { background: #fff top }
        .foo { background-color: #fff }
      $

      RedundancyAnalyzer.new(css).redundancies.must_equal({
        [sel(".bar"), sel(".baz"), sel(".foo")] => [dec("background-color", "#fff")]
      })
    end

    it "handles border and border-top matches appropriately" do
      css = %$
        .bar { border: 1px solid #fff }
        .baz { border-top: 1px solid #fff }
        .foo { border-top-width: 1px }
      $

      RedundancyAnalyzer.new(css).redundancies.must_equal({
        [sel(".bar"), sel(".baz")] => [dec("border-top", "1px solid #fff")],
        [sel(".bar"), sel(".baz"), sel(".foo")] => [dec("border-top-width", "1px")]
      })
    end

    it "reduces border matches appropriately" do
      #css = %$
        #.bar { border: 1px solid #FFF }
        #.baz { border: 1px solid #FFF }
      #$

      #RedundancyAnalyzer.new(css).redundancies.must_equal({
        #[sel(".bar"), sel(".baz")] => [dec("border", "1px solid #fff")]
      #})

      css = %$
        .bar { border: 4px solid #4F4F4F }
        .baz { border: 4px solid #4F4F4F }
        .foo { border: 4px solid #3A86CE }
      $

      RedundancyAnalyzer.new(css).redundancies.must_equal({
        [sel(".bar"), sel(".baz")] => [dec("border", "4px solid #4f4f4f")],
        [sel(".bar"), sel(".baz"), sel(".foo")] => [dec("border-style", "solid"), dec("border-width", "4px")]
      })
    end

    # TODO: someday
    # it "reports duplication within the same selector" do
    #   css = %$
    #     .bar { background: #fff top; background-color: #fff }
    #   $

    #   # TODO: need to update the reporter for this
    #   RedundancyAnalyzer.new(css).redundancies.must_equal({
    #     [sel(".bar")] => [dec("background-color", "#fff")]
    #   })
    # end
  end
end
