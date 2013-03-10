require "test_helper"

module Csscss::Parser
  module BorderWidth
    describe BorderWidth do
      include CommonParserTests

      before do
        @parser = Parser.new
        @trans = Transformer.new
      end

      it "converts shorthand rules to longhand" do
        trans("thin thick inherit 10em").must_equal([
          dec("border-top-width", "thin"),
          dec("border-right-width", "thick"),
          dec("border-bottom-width", "inherit"),
          dec("border-left-width", "10em")
        ])

        trans("thin thick").must_equal([
          dec("border-top-width", "thin"),
          dec("border-right-width", "thick"),
          dec("border-bottom-width", "thin"),
          dec("border-left-width", "thick")
        ])
      end
    end
  end
end
