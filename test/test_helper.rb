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

Debugger.settings[:autoeval] = true
Debugger.settings[:autolist] = 1
