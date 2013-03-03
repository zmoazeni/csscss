require "test_helper"

module Csscss::Parser
  describe Common do
    class CommonTest
      include Common
    end

    before { @parser = CommonTest.new }

    describe "#stri" do
      it "parses case insensitive strings" do
        @parser.stri("a").must_parse "a"
        @parser.stri("A").must_parse "a"
        @parser.stri("A").must_not_parse "b"

        @parser.stri("This too shall pass").must_parse "this TOO shall PASS"
        @parser.stri("[").must_parse "["
      end
    end

    describe "#spaces" do
      it "parses series of spaces" do
        @parser.spaces.must_parse ""
        @parser.spaces.must_parse " "
        @parser.spaces.must_parse "  "
        @parser.spaces.must_not_parse "  a"
      end
    end

    describe "#symbol" do
      it "parses case insensitive characters followed by spaces" do
        @parser.symbol("foo").must_parse "foo"
        @parser.symbol("foo").must_parse "foo  "
        @parser.symbol("foo").must_parse "Foo  "
        @parser.symbol("foo").must_not_parse " Foo  "
      end

      it "optionally captures input" do
        parsed = @parser.symbol("foo", :foo).parse("Foo  ")
        parsed[:foo].must_equal "Foo"
      end
    end

    describe "parens and between" do
      it "parses input surrounded by parens" do
        @parser.parens { @parser.symbol("foo") }.must_parse "(foo)"
        @parser.parens { @parser.symbol("foo") }.must_parse "(FOo)  "
        @parser.parens { @parser.symbol("foo") }.must_parse "(FOo  )  "
        @parser.parens { @parser.symbol("food") }.must_not_parse "(FOo"
      end

      it "parses characters surrounded" do
        @parser.between("[", "]") { @parser.symbol("foo") }.must_parse "[foo]"
      end
    end

    describe "number and numbers" do
      it "parses single numbers" do
        @parser.number.must_parse "1"
        @parser.number.must_not_parse "12"
        @parser.number.must_not_parse "a"
        @parser.number.must_not_parse "1 "
      end

      it "parses multiple numbers" do
        @parser.numbers.must_parse "1"
        @parser.numbers.must_parse "12"
        @parser.numbers.must_not_parse "12 "
        @parser.numbers.must_not_parse "1223a"
      end

      it "parses percentages" do
        @parser.percent.must_parse "100%"
        @parser.percent.must_parse "100% "
        @parser.percent.must_parse "100.344%"
        @parser.percent.must_not_parse "100 %"
      end
    end
  end
end
