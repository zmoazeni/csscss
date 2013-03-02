module Csscss
  class JSONReporter
    def initialize(redundancies)
      @redundancies = redundancies
    end

    def report
      JSON.dump(@redundancies.map {|selector_groups, declarations|
        {
          "selectors"    => selector_groups.map(&:to_s),
          "count"        => declarations.count,
          "declarations" => declarations.map(&:to_s)
        }
      })
    end
  end
end
