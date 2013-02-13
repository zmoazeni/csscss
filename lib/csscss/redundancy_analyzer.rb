class Csscss::RedundancyAnalyzer
  include Csscss

  def initialize(raw_css)
    @raw_css = raw_css
  end

  def redundancies(minimum = nil)
    rule_sets = CSSPool.CSS(@raw_css).rule_sets
    {}.tap do |results|
      rule_sets.each {|rs| downcase_all_expressions(rs) }
      rule_sets.each do |rule_set|
        rule_set.declarations.each do |dec|
          key = Declaration.from_csspool(dec)
          results[key] ||= []
          results[key] << Selector.new(rule_set.selectors.map(&:to_s))
        end
      end

      if minimum
        results.each do |key, value|
          results.delete(key) unless value.size >= minimum
        end
      end
    end
  end

  private
  def downcase_all_expressions(rule_set)
    rule_set.declarations.each {|dec| dec.property.downcase! }
  end
end
