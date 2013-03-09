require "rubygems"
require "bundler/setup"

require "minitest/autorun"
require "minitest/rg"
require "debugger"

require "csscss"

MiniTest::Spec.add_setup_hook do
  def sel(s)
    Csscss::Selector.new(Array(s))
  end

  def dec(p, v)
    Csscss::Declaration.new(p, v)
  end

  def cmatch(selectors, decs)
    Csscss::Match.new(selectors, decs)
  end
end

module MiniTest::Assertions
  def assert_parse(parser, string)
    assert parser.parse(string)
  rescue Parslet::ParseFailed => ex
    assert false, ex.cause.ascii_tree
  end

  def assert_not_parse(parser, string)
    parser.parse(string)
    assert false, "expected #{parser} to not successfully parse \"#{string}\" and it did"
  rescue Parslet::ParseFailed => ex
    assert ex
  end
end

Parslet::Atoms::DSL.infect_an_assertion :assert_parse, :must_parse, :do_not_flip
Parslet::Atoms::DSL.infect_an_assertion :assert_not_parse, :wont_parse, :do_not_flip
