require "test_helper"

module Csscss
  describe Reporter do
    it "formats string result" do
      reporter = Reporter.new({
        [sel(".foo"), sel(".bar")] => [dec("width", "1px"), dec("border", "black")],
        [sel(%w(h1 h2)), sel(".foo"), sel(".baz")] => [dec("display", "none")],
        [sel(%w(h1 h2)), sel(".bar")] => [dec("position", "relative")],
        [sel(%w(h1 h2))] => [dec("outline", "none")]
      })

     expected =<<-EXPECTED
{.foo} and {.bar} share 2 rules
{h1, h2}, {.foo} and {.baz} share 1 rule
{h1, h2} and {.bar} share 1 rule
EXPECTED
     reporter.report.must_equal expected

     expected =<<-EXPECTED
{.foo} and {.bar} share 2 rules
  - width: 1px
  - border: black
{h1, h2}, {.foo} and {.baz} share 1 rule
  - display: none
{h1, h2} and {.bar} share 1 rule
  - position: relative
EXPECTED
     reporter.report(true).must_equal expected
    end
  end
end
