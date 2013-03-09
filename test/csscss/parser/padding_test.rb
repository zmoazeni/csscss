require "test_helper"

module Csscss::Parser
  module Padding
    describe Padding do
      include CommonParserTests

      before do
        @parser = Parser.new
        @trans = Transformer.new
      end

      it "converts shorthand rules to longhand" do
        trans("1px 10% inherit 4em").must_equal([
          dec("padding-top", "1px"),
          dec("padding-right", "10%"),
          dec("padding-bottom", "inherit"),
          dec("padding-left", "4em")
        ])

        trans("1px 10% inherit").must_equal([
          dec("padding-top", "1px"),
          dec("padding-right", "10%"),
          dec("padding-bottom", "inherit"),
          dec("padding-left", "10%")
        ])

        trans("1px 10%").must_equal([
          dec("padding-top", "1px"),
          dec("padding-right", "10%"),
          dec("padding-bottom", "1px"),
          dec("padding-left", "10%")
        ])

        trans("1px").must_equal([
          dec("padding-top", "1px"),
          dec("padding-right", "1px"),
          dec("padding-bottom", "1px"),
          dec("padding-left", "1px")
        ])
      end

      it "tries the parse and returns false if it doesn't work" do
        @parser.try_parse("foo").must_equal(false)
        parsed = @parser.try_parse("1px")
        parsed[:padding][:top].must_equal("1px")
      end
    end
  end
end
