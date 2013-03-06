require "test_helper"

module Csscss::Parser
  module Background
    describe Background do
      before do
        @parser = Parser.new
        @trans = Transformer.new
      end

      def trans(s)
        @trans.apply(@parser.parse(s))
      end

      it "converts color to shorthand" do
        trans("#fff").must_equal(["background-color: #fff"])
        trans("BLACK").must_equal(["background-color: black"])
        trans("inherit").must_equal(["background-color: inherit"])
        trans("inherit none").must_equal([
          "background-color: inherit",
          "background-image: none"
        ])

        trans("#fff url(http://foo.com/bar.jpg)").must_equal([
          "background-color: #fff",
          "background-image: url(http://foo.com/bar.jpg)"
        ])
      end
    end
  end
end
