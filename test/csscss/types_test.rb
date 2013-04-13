require "test_helper"

module Csscss
  describe Declaration do
    it "< and > checks parents" do
      dec1 = Declaration.new("background", "#fff")
      dec2 = Declaration.new("background", "#fff")
      dec3 = Declaration.new("background-color", "#fff", [dec1])
      dec4 = Declaration.new("background-color", "#fff", nil)

      dec1.must_be :>, dec3
      dec3.must_be :<, dec1

      dec1.wont_be :>, dec4
      dec1.wont_be :>, dec2
      dec4.wont_be :>, dec1
    end

    it "checks ancestory against all parents" do
      dec1 = Declaration.new("border", "#fff")
      dec2 = Declaration.new("border", "#fff top")
      dec3 = Declaration.new("border-top", "#fff", [dec1, dec2])

      dec1.must_be :>, dec3
      dec2.must_be :>, dec3

      dec1.wont_be :>, dec1
      dec2.wont_be :>, dec1
      dec1.wont_be :>, dec2
      dec3.wont_be :>, dec1
    end

    it "is a derivative if it has parents" do
      dec1 = Declaration.new("background", "#fff")
      dec1.wont_be :derivative?
      Declaration.new("background-color", "#fff", [dec1]).must_be :derivative?
    end

    it "ignores parents when checking equality" do
      dec1 = Declaration.new("background", "#fff")
      dec2 = Declaration.new("background-color", "#fff", [dec1])
      dec3 = Declaration.new("background-color", "#fff", nil)

      dec1.wont_equal dec2
      dec2.wont_equal dec1

      dec2.must_equal dec3
      dec3.must_equal dec2

      dec2.hash.must_equal dec3.hash
      dec3.hash.must_equal dec2.hash
      dec3.hash.wont_equal dec1.hash

      dec2.must_be :eql?, dec3
      dec3.must_be :eql?, dec2
      dec2.wont_be :eql?, dec1
    end

    it "derivatives are handled correctly in a hash" do
      dec1 = Declaration.new("background", "#fff")
      dec2 = Declaration.new("background-color", "#fff", [dec1])
      dec3 = Declaration.new("background-color", "#fff", nil)

      h = {}
      h[dec2] = false
      h[dec3] = true

      h.keys.size.must_equal 1
      h[dec2].must_equal true
      h[dec3].must_equal true
    end

    it "equates 0 length with and without units" do
      Declaration.new("padding", "0px").must_equal Declaration.new("padding", "0")
      Declaration.new("padding", "0%").must_equal Declaration.new("padding", "0")
      Declaration.new("padding", "0").must_equal Declaration.new("padding", "0em")

      Declaration.new("padding", "1").wont_equal Declaration.new("padding", "1px")
    end
  end
end
