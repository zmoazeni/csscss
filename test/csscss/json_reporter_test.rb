require "test_helper"

module Csscss
  describe JSONReporter do
    include TypeHelpers

    it "formats json result" do
      reporter = JSONReporter.new({
        [sel(".foo"), sel(".bar")] => [dec("width", "1px"), dec("border", "black")],
        [sel("h1, h2"), sel(".foo"), sel(".baz")] => [dec("display", "none")],
        [sel("h1, h2"), sel(".bar")] => [dec("position", "relative")]
      })

      expected = [
        {
          "selectors" => %w(.foo .bar),
          "count" => 2,
          "declarations" => ["width: 1px", "border: black"]
        },
        {
          "selectors" => ["h1, h2", ".foo", ".baz"],
          "count" => 1,
          "declarations" => ["display: none"]
        },
        {
          "selectors" => ["h1, h2", ".bar"],
          "count" => 1,
          "declarations" => ["position: relative"]
        },
      ]
      reporter.report.must_equal JSON.dump(expected)
    end
  end
end
