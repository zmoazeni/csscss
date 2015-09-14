require "test_helper"

module Csscss
  describe Reporter do
    include TypeHelpers

    it "formats string result" do
      reporter = Reporter.new({
        [sel(".foo"), sel(".bar")] => [dec("width", "1px"), dec("border", "black")],
        [sel("h1, h2"), sel(".foo"), sel(".baz")] => [dec("display", "none")],
        [sel("h1, h2"), sel(".bar")] => [dec("position", "relative")]
      },[])

     expected =<<-EXPECTED
{.foo} AND {.bar} share 2 declarations
{h1, h2}, {.foo} AND {.baz} share 1 declaration
{h1, h2} AND {.bar} share 1 declaration
EXPECTED
     reporter.report(color:false).must_equal expected

     expected =<<-EXPECTED
{.foo} AND {.bar} share 2 declarations
  - width: 1px
  - border: black
{h1, h2}, {.foo} AND {.baz} share 1 declaration
  - display: none
{h1, h2} AND {.bar} share 1 declaration
  - position: relative
EXPECTED
     reporter.report(verbose:true, color:false).must_equal expected
    end

    it "prints a new line if there is nothing" do
      reporter = Reporter.new({},[])
      reporter.report().must_equal ""
    end
  end
end
