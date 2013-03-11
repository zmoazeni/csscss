require "test_helper"

module Csscss::Parser
  module Border
    describe Border do
      include CommonParserTests

      before do
        @parser = Parser.new
        @trans = Transformer.new
      end

      it "converts shorthand rules to longhand" do
        trans("1px solid #fff").must_equal([
          dec("border-top-width", "1px"),
          dec("border-top-style", "solid"),
          dec("border-top-color", "#fff"),
          dec("border-right-width", "1px"),
          dec("border-right-style", "solid"),
          dec("border-right-color", "#fff"),
          dec("border-bottom-width", "1px"),
          dec("border-bottom-style", "solid"),
          dec("border-bottom-color", "#fff"),
          dec("border-left-width", "1px"),
          dec("border-left-style", "solid"),
          dec("border-left-color", "#fff")
        ])
      end
    end
  end
end
