class Csscss::Declaration < Struct.new(:property, :value)
  def self.from_csspool(dec)
    new(dec.property.to_s, dec.expressions.join(" "))
  end
end

class Csscss::Selector < Struct.new(:selectors)
end
