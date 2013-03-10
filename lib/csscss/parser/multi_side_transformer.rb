module Csscss
  module Parser
    module MultiSideTransformer
      def self.extended(base)
        base.instance_eval do
          extend ClassMethods

          rule(@property => simple(:inherit)) {[]}

          rule({@property => {
            top:simple(:top),
            right:simple(:right),
            bottom:simple(:bottom),
            left:simple(:left)
          }}, &method(:transform_sides))
        end
      end

      module ClassMethods
        def side_declaration(side, value)
          Declaration.from_parser("#{@property}-#{side}", value)
        end

        def transform_sides(context)
          values = [context[:top], context[:right], context[:bottom], context[:left]].compact
          case values.size
          when 4
            %w(top right bottom left).zip(values).map {|side, value| side_declaration(side, value) }
          when 3
            %w(top right bottom).zip(values).map {|side, value| side_declaration(side, value) }.tap do |declarations|
              declarations << side_declaration("left", values[1])
            end
          when 2
            %w(top right).zip(values).map {|side, value| side_declaration(side, value) }.tap do |declarations|
              declarations << side_declaration("bottom", values[0])
              declarations << side_declaration("left", values[1])
            end
          when 1
            %w(top right bottom left).map do |side|
              side_declaration(side, values[0])
            end
          end
        end
      end
    end
  end
end
