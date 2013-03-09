require "test_helper"

module Csscss::Parser
  module Background
    describe Background do
      include CommonParserTests

      before do
        @parser = Parser.new
        @trans = Transformer.new
      end

      it "parses position" do
        @parser.bg_position.must_parse("10.2%")
        @parser.bg_position.must_parse("left")
        @parser.bg_position.must_parse("44em")
        @parser.bg_position.must_parse("left 11%")
        @parser.bg_position.must_parse("left bottom")
        @parser.bg_position.must_parse("inherit")
        @parser.bg_position.must_parse("bottom")
        @parser.bg_position.wont_parse("bottom left")
        @parser.bg_position.wont_parse("inherit bottom")
      end

      it "converts shorthand rules to longhand" do
        trans("rgb(111, 222, 333) none repeat-x scroll").must_equal([
          dec("background-color", "rgb(111, 222, 333)"),
          dec("background-image", "none"),
          dec("background-repeat", "repeat-x"),
          dec("background-attachment", "scroll")
        ])

        trans("inherit none inherit 10% bottom").must_equal([
          dec("background-color", "inherit"),
          dec("background-image", "none"),
          dec("background-repeat", "inherit"),
          dec("background-position", "10% bottom")
        ])

        trans("#fff url(http://foo.com/bar.jpg) bottom").must_equal([
          dec("background-color", "#fff"),
          dec("background-image", "url(http://foo.com/bar.jpg)"),
          dec("background-position", "bottom")
        ])

        trans("#fff").must_equal([dec("background-color", "#fff")])
        trans("BLACK").must_equal([dec("background-color", "black")])
      end

      it "tries the parse and returns false if it doesn't work" do
        @parser.try_parse("foo").must_equal(false)
        parsed = @parser.try_parse("black")
        parsed[:background][:bg_color].must_equal(color:{keyword:"black"})
      end
    end
  end
end
