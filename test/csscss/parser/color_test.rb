require "test_helper"

module Csscss::Parser
  describe Color do
    class ColorTest
      include Color
    end

    before { @parser = ColorTest.new }

    describe "color" do
      it "parses color" do
        @parser.color.must_parse "rgb(123, 222, 444)"
        @parser.color.must_parse "rgb(123%, 222%, 444%)"
        @parser.color.must_parse "#ffffff"
        @parser.color.must_parse "inherit"
        @parser.color.must_parse "black"
      end
    end

    describe "individual rules" do
      it "parses rgb number color" do
        @parser.rgb.must_parse "rgb(123, 222, 444)"
        @parser.rgb.must_parse "rgb  (  123  , 222  , 444  )  "
        @parser.rgb.wont_parse "rgb(1aa, 222, 444)"
      end

      it "parses rgb percentage color" do
        @parser.rgb.must_parse "rgb(123%, 222%, 444%)"
        @parser.rgb.must_parse "rgb  (  123%  , 222%  , 444%  )  "
        @parser.rgb.wont_parse "rgb(1aa%, 222%, 444%)"
      end

      it "parses hex colors" do
        @parser.hexcolor.must_parse "#ffffff"
        @parser.hexcolor.must_parse "#ffffff  "
        @parser.hexcolor.must_parse "#fff "
        @parser.hexcolor.must_parse "#fFF123"
        @parser.hexcolor.wont_parse "fFF123"
      end

      it "parses keyword colors" do
        @parser.color_keyword.must_parse "inherit"
        @parser.color_keyword.must_parse "inherit  "

        @parser.color_keyword.must_parse "black"
        @parser.color_keyword.must_parse "BLACK"
      end
    end
  end
end
