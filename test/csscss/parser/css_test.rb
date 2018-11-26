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
          @parser.comment.must_parse "/* foo */"
          @parser.comment.must_parse %$
          /* foo
           * bar
           */
          $

          @parser.comment.repeat(1).must_parse %$
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
          .baz2 { background: white /* {sdflk} */ }
        $

        trans(css).must_equal([
          rs(sel(".bar"), [dec("border", "1px solid black /* sdflk */")]),
          rs(sel(".baz"), [dec("background", "white /* sdflk */")]),
          rs(sel(".baz2"), [dec("background", "white /* {sdflk} */")])
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

      it "recognizes @media queries" do
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

          @media only screen {
            @-webkit-keyframes webkitSiblingBugfix {
              from { position: relative; }
              to { position: relative; }
            }

            a { position: relative }
          }

          h1 {
            outline: 1px;
          }
        $

        trans(css).must_equal([
          rs(sel("#foo"), [dec("background-color", "black")]),
          rs(sel("#bar"), [dec("display", "none")]),
          rs(sel("from"), [dec("position", "relative")]),
          rs(sel("to"), [dec("position", "relative")]),
          rs(sel("a"), [dec("position", "relative")]),
          rs(sel("h1"), [dec("outline", "1px")])
        ])
      end

      it "recognizes empty @media queries with no spaces" do
        css = %$
          @media (min-width: 768px) and (max-width: 979px) {}
        $

        trans(css).must_equal([
          rs(sel("@media (min-width: 768px) and (max-width: 979px)"), []),
        ])
      end

      it "recognizes empty @media queries with spaces" do
        css = %$
          @media (min-width: 768px) and (max-width: 979px) {
          }
        $

        trans(css).must_equal([
          rs(sel("@media (min-width: 768px) and (max-width: 979px)"), []),
        ])
      end

      it "ignores @import statements" do
        css = %$
          @import "foo.css";
          @import "bar.css";

          /*
          .x {
              padding: 3px;
          }
          */

          h1 {
            outline: 1px;
          }
        $

        trans(css).must_equal([
          rs(sel("h1"), [dec("outline", "1px")])
        ])
      end

      it "ignores double semicolons" do
        trans("h1 { display:none;;}").must_equal([
          rs(sel("h1"), [dec("display", "none")])
        ])
      end

      it "ignores mixin selectors" do
        css = %$
        h1 {
          /* CSSCSS START MIXIN: foo */
          font-family: serif;
          font-size: 10px;
          display: block;
          /* CSSCSS END MIXIN: foo */

          /* CSSCSS START MIXIN: bar */
          outline: 1px;
          /* CSSCSS END MIXIN: bar */

          float: left;
        }
        $

        trans(css).must_equal([
          rs(sel("h1"), [dec("float", "left")])
        ])
      end

      it "parses attributes with encoded data that include semicolons" do
        trans(%$
            .foo1 {
              background: rgb(123, 123, 123) url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAACECAYAAABRaEHiAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAHRJREFUeNqkUjESwCAIw+T/X/UHansdkLTQDnXgCAHNEW2tZbDz/Aq994bzqoY5Z8wEwiEcmmfwiRK+EGOMTVBrtz4mY9kEAyz6+E3sJ7MWBs1PaUy1lHLLmgTqElltNxLiINTBbWi0Vj5DZC9CaqZEOwQYAPhxY/7527NfAAAAAElFTkSuQmCC) repeat-x;
              display: block;
            }

            .foo2 {
              background: white url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAACECAYAAABRaEHiAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAHRJREFUeNqkUjESwCAIw+T/X/UHansdkLTQDnXgCAHNEW2tZbDz/Aq994bzqoY5Z8wEwiEcmmfwiRK+EGOMTVBrtz4mY9kEAyz6+E3sJ7MWBs1PaUy1lHLLmgTqElltNxLiINTBbWi0Vj5DZC9CaqZEOwQYAPhxY/7527NfAAAAAElFTkSuQmCC) repeat-x
            }

            .foo3 {
              outline: 1px;
              background: white url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAACECAYAAABRaEHiAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAHRJREFUeNqkUjESwCAIw+T/X/UHansdkLTQDnXgCAHNEW2tZbDz/Aq994bzqoY5Z8wEwiEcmmfwiRK+EGOMTVBrtz4mY9kEAyz6+E3sJ7MWBs1PaUy1lHLLmgTqElltNxLiINTBbWi0Vj5DZC9CaqZEOwQYAPhxY/7527NfAAAAAElFTkSuQmCC) repeat-x;
              display: block;
            }

            .foo4 {
              background: blue url(images/bg-bolt-inactive.png) no-repeat 99% 5px;
              display: block;
            }
        $).must_equal([
          rs(sel(".foo1"), [dec("background", "rgb(123, 123, 123) url(data:image/png;base64,ivborw0kggoaaaansuheugaaaaeaaacecayaaabraehiaaaagxrfwhrtb2z0d2fyzqbbzg9izsbjbwfnzvjlywr5ccllpaaaahrjrefuenqkujeswcaiw+t/x/uhansdkltqdnxgcahnew2tzbdz/aq994bzqoy5z8wewiecmmfwirk+egomtvbrtz4my9keayz6+e3sj7mwbs1pauy1lhllmgtqelltnxliintbbwi0vj5dzc9caqzeowqyaphxy/7527nfaaaaaelftksuqmcc) repeat-x"),
                            dec("display", "block")]),
          rs(sel(".foo2"), [dec("background", "white url(data:image/png;base64,ivborw0kggoaaaansuheugaaaaeaaacecayaaabraehiaaaagxrfwhrtb2z0d2fyzqbbzg9izsbjbwfnzvjlywr5ccllpaaaahrjrefuenqkujeswcaiw+t/x/uhansdkltqdnxgcahnew2tzbdz/aq994bzqoy5z8wewiecmmfwirk+egomtvbrtz4my9keayz6+e3sj7mwbs1pauy1lhllmgtqelltnxliintbbwi0vj5dzc9caqzeowqyaphxy/7527nfaaaaaelftksuqmcc) repeat-x")]),
          rs(sel(".foo3"), [dec("outline", "1px"),
                            dec("background", "white url(data:image/png;base64,ivborw0kggoaaaansuheugaaaaeaaacecayaaabraehiaaaagxrfwhrtb2z0d2fyzqbbzg9izsbjbwfnzvjlywr5ccllpaaaahrjrefuenqkujeswcaiw+t/x/uhansdkltqdnxgcahnew2tzbdz/aq994bzqoy5z8wewiecmmfwirk+egomtvbrtz4my9keayz6+e3sj7mwbs1pauy1lhllmgtqelltnxliintbbwi0vj5dzc9caqzeowqyaphxy/7527nfaaaaaelftksuqmcc) repeat-x"),
                            dec("display", "block")]),
          rs(sel(".foo4"), [dec("background", "blue url(images/bg-bolt-inactive.png) no-repeat 99% 5px"),
                            dec("display", "block")])
        ])
      end

      it "parses attributes with special characters" do
        css = %$

        #menu a::before {
            content: "{";
            left: -6px;
        }

        #menu a::after {
            content: "}";
            right: -6px;
        }

        #menu a::weird {
            content: "@";
            up: -2px;
        }

        #menu a::after_all {
            content: '{';
            right: -6px;
        }

        $

        trans(css).must_equal([
          rs(sel("#menu a::before"), [dec("content", '"{"'),
            dec("left", "-6px")
            ]),
          rs(sel("#menu a::after"), [dec("content", '"}"'),
            dec("right", "-6px")
            ]),
          rs(sel("#menu a::weird"), [dec("content", '"@"'),
              dec("up", "-2px")
            ]),
          rs(sel("#menu a::after_all"), [dec("content", "'{'"),
              dec("right", "-6px")
            ])
        ])
      end
    end
  end
end
