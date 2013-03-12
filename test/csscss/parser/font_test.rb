require "test_helper"

module Csscss::Parser
  module Font
    describe self do
      include CommonParserTests

      before do
        @parser = Parser.new
        @trans = Transformer.new
      end

      it "converts shorthand rules to longhand" do
        trans("10% Gill, 'Lucida Sans'").must_equal([
          dec("font-size", "10%"),
          dec("font-family", "Gill, 'Lucida Sans'")
        ])

        trans("normal small-caps 100 10% / 33 Gill, Helvetica, \"Lucida Sans\", cursive").must_equal([
          dec("font-style", "normal"),
          dec("font-variant", "small-caps"),
          dec("font-weight", "100"),
          dec("font-size", "10%"),
          dec("line-height", "33"),
          dec("font-family", 'Gill, Helvetica, "Lucida Sans", cursive')
        ])
      end

      it "parses font family" do
        @parser.font_family.must_parse("\"Lucida\"")
        @parser.font_family.must_parse("\"Lucida Sans\"")
        @parser.font_family.must_parse("Gill")
        @parser.font_family.must_parse('Gill, Helvetica, "Lucida Sans", cursive')
      end

      it "ignores literal fonts" do
        trans("caption").must_equal([])
        trans("icon").must_equal([])
        trans("menu").must_equal([])
      end
    end
  end
end
