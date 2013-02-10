# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'csscss/version'

Gem::Specification.new do |gem|
  gem.name          = "csscss"
  gem.version       = Csscss::VERSION
  gem.authors       = ["Zach Moazeni"]
  gem.email         = ["zach.moazeni@gmail.com"]
  gem.description   = %q{A CSS redundancy analyzer that analyzes redundancy.}
  gem.summary       = %q{A CSS redundancy analyzer that analyzes redundancy.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "csspool", "~> 3.0"
  gem.add_dependency "parslet", "~> 1.5"
end
