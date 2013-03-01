module Csscss
  class RedundancyAnalyzer
    def initialize(raw_css)
      @raw_css = raw_css
    end

    def redundancies(minimum = nil)
      rule_sets = CSSPool.CSS(@raw_css).rule_sets
      matches = {}
      rule_sets.each do |rule_set|
        rule_set.declarations.each do |dec|
          dec.property.downcase!
          dec.expressions do |exp|
            exp.value.downcase!
          end

          dec_key = Declaration.from_csspool(dec)
          sel = Selector.new(rule_set.selectors.map(&:to_s))
          matches[dec_key] ||= []
          matches[dec_key] << sel
        end
      end

      inverted_matches = {}
      matches.each do |declaration, selector_groups|
        if selector_groups.size > 1
          selector_groups.combination(2).each do |two_selectors|
            inverted_matches[two_selectors] ||= []
            inverted_matches[two_selectors] << declaration
          end
        end
      end

      if minimum
        inverted_matches.delete_if do |key, declarations|
          declarations.size < minimum
        end
      end

      final_inverted_matches = inverted_matches.dup
      inverted_matches.to_a[0..-2].each_with_index do |(selector_group1, declarations1), index|
        inverted_matches.to_a[(index + 1)..-1].each do |selector_group2, declarations2|
          if declarations1 == declarations2
            final_inverted_matches.delete(selector_group1)
            final_inverted_matches.delete(selector_group2)
            key = (selector_group1 + selector_group2).sort.uniq
            final_inverted_matches[key] ||= []
            final_inverted_matches[key].concat(declarations1 + declarations2).uniq!
          end
        end
      end

      sorted_array = final_inverted_matches.sort {|(_, v1), (_, v2)| v2.size <=> v1.size }
      {}.tap do |sorted_hash|
        sorted_array.each do |key, value|
          sorted_hash[key.sort] = value.sort
        end
      end
    end
  end
end
