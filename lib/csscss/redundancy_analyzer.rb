class Csscss::RedundancyAnalyzer
  include Csscss

  def initialize(raw_css)
    @raw_css = raw_css
  end

  def redundancies
    rule_sets = CSSPool.CSS(@raw_css).rule_sets
    matches = {}
    rule_sets.combination(2) do |rule_set1, rule_set2|
      same_decs = rule_set1.declarations.select do |dec|
        rule_set2.declarations.include?(dec)
      end

      unless same_decs.empty?
        same_decs = same_decs.map {|dec| Declaration.from_csspool(dec) }

        matches[rule_set1] ||= []
        matches[rule_set1] << RuleSet.new(rule_set2.selectors.map(&:to_s), same_decs)
      end
    end

    matches.map {|rule_set, raw_matches| Match.new(RuleSet.from_csspool(rule_set), raw_matches) }
  end
end

class Csscss::RuleSet < Struct.new(:selectors, :declarations)
  def self.from_csspool(rule_set)
    new(rule_set.selectors.map(&:to_s), rule_set.declarations.map {|dec| Csscss::Declaration.from_csspool(dec)})
  end
end

class Csscss::Declaration < Struct.new(:property, :value)
  def self.from_csspool(dec)
    new(dec.property.to_s, dec.expressions.join(" "))
  end
end

class Csscss::Match < Struct.new(:rule_set, :matched_rule_set)
end

