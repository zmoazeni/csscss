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

class Csscss::Match < Struct.new(:rule_set, :matched_rule_sets)
end


