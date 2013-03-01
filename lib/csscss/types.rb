module Csscss
  class Declaration < Struct.new(:property, :value)
    def self.from_csspool(dec)
      new(dec.property.to_s, dec.expressions.join(" "))
    end

    def <=>(other)
      property <=> other.property
    end
  end

  class Selector < Struct.new(:selectors)
    def <=>(other)
      selectors <=> other.selectors
    end
  end
end
