#! /usr/bin/env ruby

require "byebug"
require "csscss"

raise "need a file name" unless ARGV[0]
contents = File.read(ARGV[0])
rule_sets = Csscss::Parser::Css.parse(contents)
