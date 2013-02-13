class Csscss::RedundancyAnalyzer
  include Csscss

  def initialize(raw_css)
    @raw_css = raw_css
  end

  def redundancies(minimum = nil)
    rule_sets = CSSPool.CSS(@raw_css).rule_sets
    {}.tap do |matches|
      used = {}
      rule_sets.each {|rs| downcase_all_expressions(rs) }
      rule_sets[0..-2].each.with_index do |rule_set1, index|
        rule_sets[(index + 1)..-1].each do |rule_set2|
          rule_set1.declarations.each do |dec|
            unless used[[rule_set1, dec]]
              if rule_set2.declarations.include?(dec)
                sel1 = Selector.new(rule_set1.selectors.map(&:to_s))
                sel2 = Selector.new(rule_set2.selectors.map(&:to_s))
                dec_key = Declaration.from_csspool(dec)
                matches[sel1] ||= {}
                matches[sel1][dec_key] ||= []
                matches[sel1][dec_key] << sel2
                used[[rule_set2,dec]] = true
              end
            end
          end
        end
      end

      if minimum
        matches.each do |rs1, dec_map|
          dec_map.each do |dec, other_rule_sets|
            dec_map.delete(dec) if other_rule_sets.size < minimum - 1
          end

          matches.delete(rs1) if dec_map.keys.size == 0
        end
      end
    end
  end

  private
  def downcase_all_expressions(rule_set)
    rule_set.declarations.each {|dec| dec.property.downcase! }
  end
end
