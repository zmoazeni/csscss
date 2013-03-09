module Csscss
  class Declaration < Struct.new(:property, :value, :parent)
    def self.from_csspool(dec)
      new(dec.property.to_s, dec.expressions.join(" "))
    end

    def self.from_parser(property, value)
      new(property.to_s, value.to_s.downcase.strip)
    end

    def derivative?
      !parent.nil?
    end

    def without_parent
      if derivative?
        dup.tap do |duped|
          duped.parent = nil
        end
      else
        self
      end
    end

    def ==(other)
      if derivative?
        without_parent == other
      else
        super(other.respond_to?(:without_parent) ? other.without_parent : other)
      end
    end

    def hash
      derivative? ? without_parent.hash : super
    end

    def eql?(other)
      hash == other.hash
    end

    def <=>(other)
      property <=> other.property
    end

    def >(other)
      self == other.parent
    end

    def <(other)
      other > self
    end

    def to_s
      base = "#{property}: #{value}"
      if parent
        "#{base} (parent: #{parent})"
      else
        base
      end
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
