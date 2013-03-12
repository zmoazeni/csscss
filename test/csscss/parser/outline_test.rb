require "test_helper"

module Csscss::Parser
  module Outline
    describe self do
      include CommonParserTests

      before do
        @parser = Parser.new
        @trans = Transformer.new
      end

      it "converts shorthand rules to longhand" do
        trans("1px solid blue").must_equal([
          dec("outline-width", "1px"),
          dec("outline-style", "solid"),
          dec("outline-color", "blue")
        ])

        trans("solid").must_equal([
          dec("outline-style", "solid")
        ])
      end
    end
  end
end
