require "rubygems"
require "bundler/setup"
require "parslet/rig/rspec"

require "csscss"

RSpec.configure do |config|

  def sel(s)
    Csscss::Selector.new(Array(s))
  end

  def dec(p, v)
    Csscss::Declaration.new(p, v)
  end
end
