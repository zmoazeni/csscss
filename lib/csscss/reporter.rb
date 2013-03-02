module Csscss
  class Reporter
    def initialize(redundancies)
      @redundancies = redundancies
    end

    def report(verbose = false)
      io = StringIO.new
      @redundancies.each do |selector_groups, declarations|
        selector_groups = selector_groups.map {|selectors| "{#{selectors}}" }
        last_selector = selector_groups.pop
        count = declarations.size
        io.puts %Q(#{selector_groups.join(", ")} and #{last_selector} share #{count} rule#{"s" if count > 1})
        if verbose
          declarations.each {|dec| io.puts "  - #{dec}" }
        end
      end

      io.rewind
      io.read
    end
  end
end
