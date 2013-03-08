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

      it "parses position" do
        @parser.bg_position.must_parse("10.2%")
        @parser.bg_position.must_parse("left")
        @parser.bg_position.must_parse("44em")
        @parser.bg_position.must_parse("left 11%")
        @parser.bg_position.must_parse("left bottom")
        @parser.bg_position.must_parse("inherit")
        @parser.bg_position.must_parse("bottom")
        @parser.bg_position.must_not_parse("bottom left")
        @parser.bg_position.must_not_parse("inherit bottom")
      end

      it "converts shorthand rules to longhand" do
        trans("rgb(111, 222, 333) none repeat-x scroll").must_equal([
          "background-color: rgb(111, 222, 333)",
          "background-image: none",
          "background-repeat: repeat-x",
          "background-attachment: scroll"
        ])

        trans("inherit none inherit 10% bottom").must_equal([
          "background-color: inherit",
          "background-image: none",
          "background-repeat: inherit",
          "background-position: 10% bottom"
        ])

        trans("#fff url(http://foo.com/bar.jpg) bottom").must_equal([
          "background-color: #fff",
          "background-image: url(http://foo.com/bar.jpg)",
          "background-position: bottom"
        ])

        trans("#fff").must_equal(["background-color: #fff"])
        trans("BLACK").must_equal(["background-color: black"])
        trans("inherit").must_equal(["background: inherit"])
      end

      it "doesn't parse unknown values" do
        @parser.must_not_parse("foo")
      end
    end
  end
end
