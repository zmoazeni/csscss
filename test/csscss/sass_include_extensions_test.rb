require "test_helper"
require "tempfile"
require "csscss/sass_include_extensions"

module Csscss
  describe "sass import extensions" do
    it "should add comments before and after mixin properties" do
      scss =<<-SCSS
      @mixin foo {
        font: {
          family: serif;
          size: 10px;
        }

        display: block;
      }

      @mixin bar {
        outline: 1px;
      }

      h1 {
        @include foo;
        @include bar;
      }
      SCSS


      css =<<-CSS
h1 {
  /* CSSCSS START MIXIN: foo */
  font-family: serif;
  font-size: 10px;
  display: block;
  /* CSSCSS END MIXIN: foo */
  /* CSSCSS START MIXIN: bar */
  outline: 1px;
  /* CSSCSS END MIXIN: bar */ }
      CSS

      Sass::Engine.new(scss, syntax: :scss, cache: false).render.must_equal(css)
    end

    it "should insert comments even with imported stylesheets" do
      Tempfile.open(['foo', '.scss']) do |f|
        f << <<-SCSS
          @mixin foo {
            outline: 1px;
          }

          h1 {
            @include foo;
          }
        SCSS
        f.close

        css =<<-CSS
h1 {
  /* CSSCSS START MIXIN: foo */
  outline: 1px;
  /* CSSCSS END MIXIN: foo */ }
      CSS

        Sass::Engine.new("@import '#{f.path}'", syntax: :scss, cache: false).render.must_equal(css)
      end
    end
  end
end
