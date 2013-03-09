require "test_helper"

module Csscss::Parser
  module Margin
    describe Margin do
      include CommonParserTests

      before do
        @parser = Parser.new
        @trans = Transformer.new
      end

      it "converts shorthand rules to longhand" do
        trans("1px 10% inherit auto").must_equal([
          dec("margin-top", "1px"),
          dec("margin-right", "10%"),
          dec("margin-bottom", "inherit"),
          dec("margin-left", "auto")
        ])

        trans("1px 10% inherit").must_equal([
          dec("margin-top", "1px"),
          dec("margin-right", "10%"),
          dec("margin-bottom", "inherit"),
          dec("margin-left", "10%")
        ])

        trans("1px 10%").must_equal([
          dec("margin-top", "1px"),
          dec("margin-right", "10%"),
          dec("margin-bottom", "1px"),
          dec("margin-left", "10%")
        ])

        trans("1px").must_equal([
          dec("margin-top", "1px"),
          dec("margin-right", "1px"),
          dec("margin-bottom", "1px"),
          dec("margin-left", "1px")
        ])
      end

      it "tries the parse and returns false if it doesn't work" do
        @parser.try_parse("foo").must_equal(false)
        parsed = @parser.try_parse("1px")
        parsed[:margin][:top].must_equal("1px")
      end
    end
  end
end
