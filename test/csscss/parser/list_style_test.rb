require "test_helper"

module Csscss::Parser
  module ListStyle
    describe ListStyle do
      include CommonParserTests

      before do
        @parser = Parser.new
        @trans = Transformer.new
      end

      it "converts shorthand rules to longhand" do
        trans("circle outside url('foo.jpg')").must_equal([
          dec("list-style-type", "circle"),
          dec("list-style-position", "outside"),
          dec("list-style-image", "url('foo.jpg')")
        ])
      end

      it "tries the parse and returns false if it doesn't work" do
        @parser.try_parse("foo").must_equal(false)
        parsed = @parser.try_parse("circle")
        parsed[:list_style][:list_style_type].must_equal(type:"circle")
      end
    end
  end
end
