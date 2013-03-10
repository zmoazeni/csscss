require "test_helper"

module Csscss::Parser
  module BorderColor
    describe BorderColor do
      include CommonParserTests

      before do
        @parser = Parser.new
        @trans = Transformer.new
      end

      it "converts shorthand rules to longhand" do
        trans("#fff transparent black rgb(1, 2, 3)").must_equal([
          dec("border-top-color", "#fff"),
          dec("border-right-color", "transparent"),
          dec("border-bottom-color", "black"),
          dec("border-left-color", "rgb(1, 2, 3)")
        ])

        trans("#fff black").must_equal([
          dec("border-top-color", "#fff"),
          dec("border-right-color", "black"),
          dec("border-bottom-color", "#fff"),
          dec("border-left-color", "black")
        ])
      end
    end
  end
end
