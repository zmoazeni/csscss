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
        inverted_matches[selector_groups] ||= []
        inverted_matches[selector_groups] << declaration
      end

      if minimum
        inverted_matches.delete_if do |_, declarations|
          declarations.size < minimum
        end
      end

      sorted_array = inverted_matches.sort {|(_, v1), (_, v2)| v2.size <=> v1.size }
      {}.tap do |sorted_hash|
        sorted_array.each do |key, value|
          sorted_hash[key] = value
        end
      end
    end
  end
end
