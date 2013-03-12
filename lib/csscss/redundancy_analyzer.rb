module Csscss
  class RedundancyAnalyzer
    def initialize(raw_css)
      @raw_css = raw_css
    end

    def redundancies(minimum = nil)
      rule_sets = CSSPool.CSS(@raw_css).rule_sets
      matches = {}
      parents = {}
      rule_sets.each do |rule_set|
        rule_set.declarations.each do |dec|
          sel = Selector.new(rule_set.selectors.map(&:to_s))
          original_dec = Declaration.from_csspool(dec)

          if parser = shorthand_parser(dec.property)
            if new_decs = parser.parse(dec.property, dec.expressions)
              if original_dec.property == "border"
                %w(border-top border-right border-bottom border-left).each do |property|
                  border_dec = Declaration.new(property, original_dec.value)
                  parents[border_dec] ||= []
                  (parents[border_dec] << original_dec).uniq!
                  border_dec.parents = parents[border_dec]

                  matches[border_dec] ||= []
                  matches[border_dec] << sel
                  matches[border_dec].uniq!
                end
              end

              new_decs.each do |new_dec|
                # replace any non-derivatives with derivatives
                existing = matches.delete(new_dec) || []
                existing << sel
                parents[new_dec] ||= []
                (parents[new_dec] << original_dec).uniq!
                new_dec.parents = parents[new_dec]
                matches[new_dec] = existing
                matches[new_dec].uniq!
              end
            end
          end

          matches[original_dec] ||= []
          matches[original_dec] << sel
          matches[original_dec].uniq!
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

      # combines selector keys by common declarations
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

      # trims any derivative declarations alongside shorthand
      final_inverted_matches.each do |selectors, declarations|
        redundant_derivatives = declarations.select do |dec|
          dec.derivative? && declarations.detect {|dec2| dec2 > dec }
        end
        unless redundant_derivatives.empty?
          final_inverted_matches[selectors] = declarations - redundant_derivatives
        end

        # border needs to be reduced even more
        %w(width style color).each do |property|
          decs = final_inverted_matches[selectors].select do |dec|
            dec.derivative? && dec.property =~ /border-\w+-#{property}/
          end
          if decs.size == 4 && decs.map(&:value).uniq.size == 1
            final_inverted_matches[selectors] -= decs
            final_inverted_matches[selectors] << Declaration.new("border-#{property}", decs.first.value)
          end
        end
      end


      # sort hash by number of matches
      sorted_array = final_inverted_matches.sort {|(_, v1), (_, v2)| v2.size <=> v1.size }
      {}.tap do |sorted_hash|
        sorted_array.each do |key, value|
          sorted_hash[key.sort] = value.sort
        end
      end
    end

    def shorthand_parser(property)
      case property
      when "background"   then Parser::Background
      when "list-style"   then Parser::ListStyle
      when "margin"       then Parser::Margin
      when "padding"      then Parser::Padding
      when "border"       then Parser::Border
      when "border-width" then Parser::BorderWidth
      when "border-style" then Parser::BorderStyle
      when "border-color" then Parser::BorderColor
      when "outline"      then Parser::Outline
      when "font"         then Parser::Font
      when "border-top", "border-right", "border-bottom", "border-left"
        Parser::BorderSide
      end
    end
  end
end
