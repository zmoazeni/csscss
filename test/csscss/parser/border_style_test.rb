require "test_helper"

module Csscss::Parser
  module BorderStyle
    describe BorderStyle do
      include CommonParserTests

      before do
        @parser = Parser.new
        @trans = Transformer.new
      end

      it "converts shorthand rules to longhand" do
        trans("none dashed solid ridge").must_equal([
          dec("border-top-style", "none"),
          dec("border-right-style", "dashed"),
          dec("border-bottom-style", "solid"),
          dec("border-left-style", "ridge")
        ])

        trans("none dashed").must_equal([
          dec("border-top-style", "none"),
          dec("border-right-style", "dashed"),
          dec("border-bottom-style", "none"),
          dec("border-left-style", "dashed")
        ])
      end
    end
  end
end
