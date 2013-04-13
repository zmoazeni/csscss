module Csscss
  class Declaration < Struct.new(:property, :value, :parents)
    def self.from_csspool(dec)
      new(dec.property.to_s.downcase, dec.expressions.join(" ").downcase)
    end

    def self.from_parser(property, value, clean = true)
      value = value.to_s
      property = property.to_s
      if clean
        value = value.downcase
        property = property.downcase
      end
      new(property, value.strip)
    end

    def derivative?
      !parents.nil?
    end

    def without_parents
      if derivative?
        dup.tap do |duped|
          duped.parents = nil
        end
      else
        self
      end
    end

    def ==(other)
      if other.respond_to?(:property) && other.respond_to?(:value)
        property == other.property && value == other.value
      else
        false
      end
    end

    def normalized_value
      zero_units = Csscss::Parser::Common::UNITS.map {|u| '0' + u}
      if zero_units.include? value
        "0"
      else
        value
      end
    end

    def hash
      [property, normalized_value].hash
    end

    def eql?(other)
      hash == other.hash
    end

    def <=>(other)
      property <=> other.property
    end

    def >(other)
      other.derivative? && other.parents.include?(self)
    end

    def <(other)
      other > self
    end

    def to_s
      "#{property}: #{value}"
    end

    def inspect
      if parents
        "<#{self.class} #{to_s} (parents: #{parents})>"
      else
        "<#{self.class} #{to_s}>"
      end
    end
  end

  class Selector < Struct.new(:selectors)
    def self.from_parser(selectors)
      new(selectors.to_s.strip)
    end

    def <=>(other)
      selectors <=> other.selectors
    end

    def to_s
      selectors
    end

    def inspect
      "<#{self.class} #{selectors}>"
    end
  end

  class Ruleset < Struct.new(:selectors, :declarations)
  end
end
