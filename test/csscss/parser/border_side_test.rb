require "test_helper"

module Csscss::Parser
  module BorderSide
    describe self do
      include CommonParserTests

      before do
        @parser = Parser.new("top")
      end

      def trans_top(s)
        Transformer.new.apply(@parser.parse(s))
      end
      alias_method :trans, :trans_top

      def trans_bottom(s)
        Transformer.new.apply(Parser.new("bottom").parse(s))
      end

      it "converts shorthand rules to longhand" do
        trans_top("thin").must_equal([
          dec("border-top-width", "thin")
        ])

        trans_bottom("rgb(1, 2, 3)").must_equal([
          dec("border-bottom-color", "rgb(1, 2, 3)")
        ])

        trans_top("thin solid #fff").must_equal([
          dec("border-top-width", "thin"),
          dec("border-top-style", "solid"),
          dec("border-top-color", "#fff")
        ])

        trans_bottom("thin solid #fff").must_equal([
          dec("border-bottom-width", "thin"),
          dec("border-bottom-style", "solid"),
          dec("border-bottom-color", "#fff")
        ])
      end
    end
  end
end
