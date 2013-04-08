module Csscss
  class CLI
    def initialize(argv)
      @argv               = argv
      @verbose            = false
      @color              = true
      @minimum            = 3
      @compass            = false
      @ignored_properties = []
      @ignored_selectors  = []
    end

    def run
      parse(@argv)
      execute
    end

    def execute

      all_redundancies = @argv.map do |filename|
        contents = if %w(.scss .sass).include?(File.extname(filename).downcase) && !(filename =~ URI.regexp)
          begin
            require "sass"
          rescue LoadError
            puts "Must install sass gem before parsing sass/scss files"
            exit 1
          end

          sass_options = {cache:false}
          sass_options[:load_paths] = Compass.configuration.sass_load_paths if @compass
          begin
            Sass::Engine.for_file(filename, sass_options).render
          rescue Sass::SyntaxError => e
            if e.message =~ /compass/ && !@compass
              puts "Enable --compass option to use compass's extensions"
              exit 1
            else
              raise e
            end
          end
        else
          open(filename) {|f| f.read }
        end

        RedundancyAnalyzer.new(contents).redundancies(minimum:           @minimum,
                                                     ignored_properties: @ignored_properties,
                                                     ignored_selectors:  @ignored_selectors)
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

      if @json
        puts JSONReporter.new(combined_redundancies).report
      else
        report = Reporter.new(combined_redundancies).report(verbose:@verbose, color:true)
        puts report unless report.empty?
      end

    rescue Parslet::ParseFailed => e
      line, column = e.cause.source.line_and_column
      puts "Had a problem parsing the css at line: #{line}, column: #{column}".red
      if ENV['CSSCSS_DEBUG'] == 'true'
        puts e.cause.ascii_tree.red
      else
        puts "Run with CSSCSS_DEBUG=true for verbose parser errors".red
      end
      exit 1
    end

    def parse(argv)
      opts = OptionParser.new do |opts|
        opts.banner  = "Usage: csscss [files..]"
        opts.version = Csscss::VERSION

        opts.on("-v", "--[no-]verbose", "Display each rule") do |v|
          @verbose = v
        end

        opts.on("--[no-]color", "Colorizes output") do |c|
          @color = c
        end

        opts.on("-n", "--num N", Integer, "Print matches with at least this many rules. Defaults to 3") do |n|
          @minimum = n
        end

        opts.on("--ignore-properties property1,property2,...", Array, "Ignore these properties when finding matches") do |ignored_properties|
          @ignored_properties = ignored_properties
        end

        opts.on('--ignore-selectors "selector1","selector2",...', Array, "Ignore these selectors when finding matches") do |ignored_selectors|
          @ignored_selectors = ignored_selectors
        end

        opts.on("-V", "--version", "Show version") do |v|
          puts opts.ver
          exit
        end

        opts.on("--[no-]compass", "Enables compass extensions when parsing sass/scss") do |compass|
          if @compass = compass
            begin
              require "compass"
            rescue LoadError
              puts "Must install compass gem before enabling its extensions"
              exit 1
            end
          end
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
