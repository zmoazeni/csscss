module Csscss
  class Reporter
    def initialize(redundancies)
      @redundancies = redundancies
    end

    def report(verbose = false)
      io = StringIO.new
      @redundancies.each do |selector_groups, declarations|
        selector_groups = selector_groups.map {|selectors| "{#{selectors.selectors.join(", ")}}" }
        last_selector = selector_groups.pop
        count = declarations.size
        unless selector_groups.empty?
          io.puts %Q(#{selector_groups.join(", ")} and #{last_selector} share #{count} rule#{"s" if count > 1})
          if verbose
            declarations.each do |dec|
              io.puts "  - #{dec.property}: #{dec.value}"
            end
          end
        end
      end

      io.rewind
      io.read
    end
  end
end
