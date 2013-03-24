require "test_helper"

module Csscss::Parser
  module Css
    describe self do
      include CommonParserTests::Helpers
      include TypeHelpers

      before do
        @parser = Parser.new
        @trans = Transformer.new
      end

      describe "parsing" do
        it "parses css" do
          @parser.must_parse "h1 { display: none }"
          @parser.must_parse "\nh1 { display: none; }"
          @parser.must_parse %$
            .bar { border: 1px solid black }
          $

          @parser.wont_parse ""
        end

        it "parses comments" do
          @parser.css_space?.must_parse "/* foo */"
          @parser.css_space?.must_parse %$
          /* foo
           * bar
           */
          $

          @parser.css_space?.must_parse %$
            /* foo */
            /* bar */
          $
        end
      end

      it "transforms css" do
        css = %$
          h1, h2 { display: none; position: relative; outline:none}
          .foo { display: none; width: 1px }
          .bar { border: 1px solid black }
          .baz {
            background-color: black;
            background-style: solid
          }
        $

        trans(css).must_equal([
          rs(sel("h1, h2"), [dec("display", "none"), dec("position", "relative"), dec("outline", "none")]),
          rs(sel(".foo"), [dec("display", "none"), dec("width", "1px")]),
          rs(sel(".bar"), [dec("border", "1px solid black")]),
          rs(sel(".baz"), [dec("background-color", "black"), dec("background-style", "solid")])
        ])
      end

      it "skips comments" do
        css = %$
          /* some comment
           * foo
          */
          .bar { border: 1px solid black /* sdflk */ }
          .baz { background: white /* sdflk */ }
        $

        trans(css).must_equal([
          rs(sel(".bar"), [dec("border", "1px solid black /* sdflk */")]),
          rs(sel(".baz"), [dec("background", "white /* sdflk */")])
        ])
      end

      it "skips rules that are commented out" do
        css = %$
          /*
             bar { border: 1px solid black }
          */

          /* foo */
          .baz {
            background: white;
            /* bar */
            border: 1px;
          }
        $

        trans(css).must_equal([
          rs(sel(".baz"), [dec("background", "white"), dec("border", "1px")])
        ])
      end

      it "parses commented attributes" do
        css = %$
          .foo {
            /*
              some comment
            */
          }
        $

        trans(css).must_equal([
          rs(sel(".foo"), [])
        ])
      end

      it "recognizes media queries" do
        css = %$
          @media only screen {
            /* some comment */
            #foo {
              background-color: black;
            }

            #bar {
              display: none;
            }
          }

          h1 {
            outline: 1px;
          }
        $

        trans(css).must_equal([
          rs(sel("#foo"), [dec("background-color", "black")]),
          rs(sel("#bar"), [dec("display", "none")]),
          rs(sel("h1"), [dec("outline", "1px")])
        ])
      end

      it "ignores double semicolons" do
        trans("h1 { display:none;;}").must_equal([
          rs(sel("h1"), [dec("display", "none")])
        ])
      end
    end
  end
end
