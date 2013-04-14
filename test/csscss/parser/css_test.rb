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
          rs(sel("h1, h2"), [dec("display", "none"), dec("position", "relative"), dec("outline", "none")], md(2)),
          rs(sel(".foo"), [dec("display", "none"), dec("width", "1px")], md(3)),
          rs(sel(".bar"), [dec("border", "1px solid black")], md(4)),
          rs(sel(".baz"), [dec("background-color", "black"), dec("background-style", "solid")], md(5))
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
          rs(sel(".bar"), [dec("border", "1px solid black /* sdflk */")], md(5)),
          rs(sel(".baz"), [dec("background", "white /* sdflk */")], md(6))
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
          rs(sel(".baz"), [dec("background", "white"), dec("border", "1px")], md(7))
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
          rs(sel(".foo"), [], md(2))
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
          rs(sel("#foo"), [dec("background-color", "black")], md(4)),
          rs(sel("#bar"), [dec("display", "none")], md(8)),
          rs(sel("h1"), [dec("outline", "1px")], md(13))
        ])
      end

      it "ignores double semicolons" do
        trans("h1 { display:none;;}").must_equal([
          rs(sel("h1"), [dec("display", "none")], md(1))
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
    end
  end
end
