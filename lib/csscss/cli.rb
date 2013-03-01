module Csscss
  class CLI
    def initialize(argv)
      @argv = argv
      @verbose = false
      @minimum = 3
    end

    def run
      parse(@argv)
      execute
    end

    def execute
      all_redundancies = @argv.map do |filename|
        contents = File.read(filename)
        RedundancyAnalyzer.new(contents).redundancies(@minimum)
      end

      combined_redundancies = all_redundancies.inject({}) do |combined, redundancies|
        if combined.empty?
          redundancies
        else
          combined.merge(redundancies) do |_, v1, v2|
            (v1 + v2).uniq
          end
        end
      end

      puts Reporter.new(combined_redundancies).report(@verbose)
    end

    def parse(argv)
      opts = OptionParser.new do |opts|
        opts.banner  = "Usage: csscss [files..]"
        opts.version = Csscss::VERSION

        opts.on("-v", "--[no-]verbose", "Display each rule") do |v|
          @verbose = v
        end

        opts.on("-n", "--num N", Integer, "Print matches with at least this many rules. Defaults to 3") do |n|
          @minimum = n
        end

        opts.on("-V", "--version", "Show version") do |v|
          puts opts.ver
          exit
        end

        opts.on("-j", "--[no-]json", "Output results in JSON") do |j|
          @json = j
        end

        opts.on_tail("-h", "--help", "Show this message") do
          print_help(opts)
        end
      end
      opts.parse!(argv)

      print_help(opts) if argv.empty?
    rescue OptionParser::ParseError
      print_help(opts)
    end

    private
    def print_help(opts)
      puts opts
      exit
    end

    class << self
      def run(argv)
        new(argv).run
      end
    end
  end
end
