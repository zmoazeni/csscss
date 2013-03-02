module Csscss
  class Declaration < Struct.new(:property, :value)
    def self.from_csspool(dec)
      new(dec.property.to_s, dec.expressions.join(" "))
    end

    def <=>(other)
      property <=> other.property
    end

    def to_s
      "#{property}: #{value}"
    end

    def inspect
      "<#{self.class} #{to_s}>"
    end
  end

  class Selector < Struct.new(:selectors)
    def <=>(other)
      selectors <=> other.selectors
    end

    def to_s
      selectors.join(", ")
    end

    def inspect
      "<#{self.class} #{selectors}>"
    end
  end
end
