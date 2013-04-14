module Csscss
  class CLI
    def initialize(argv)
      @argv               = argv
      @verbose            = false
      @color              = !windows_1_9
      @minimum            = 3
      @compass            = false
      @ignored_properties = []
      @ignored_selectors  = []
      @match_shorthand   = true
    end

    def run
      parse(@argv)
      execute
    end

    def gem_installed?(gem_name)
      begin
        require gem_name
      rescue LoadError
        return false
      end
      true
    end

    def load_sass_file(filename)
      if !gem_installed?('sass') then
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
    end

    def load_less_file(filename)
      if !gem_installed?('less') then
        puts "Must install less gem before parsing less files (try \"gem install less\", or add less to your Gemfile)"
        exit 1
      end

      begin
        contents = open(filename) {|f| f.read }
        Less::Parser.new.parse(contents).to_css         
      rescue Less::ParseError => e 
        puts "Less parse error"
        exit 1
      end
    end

    def load_css_file(filename)
      open(filename) {|f| f.read }
    end

    def execute
      warn_old_debug_flag if ENV["CSSCSS_DEBUG"]

      all_contents= @argv.map do |filename|
        if %w(.scss .sass).include?(File.extname(filename).downcase) && !(filename =~ URI.regexp)
          load_sass_file(filename)
        elsif %w(.less).include?(File.extname(filename).downcase) && !(filename =~ URI.regexp) 
          load_less_file(filename)
        else
          load_css_file(filename)
        end
      end.join("\n")

      unless all_contents.strip.empty?
        redundancies = RedundancyAnalyzer.new(all_contents).redundancies(
          minimum:            @minimum,
          ignored_properties: @ignored_properties,
          ignored_selectors:  @ignored_selectors,
          match_shorthand:    @match_shorthand
        )

        if @json
          puts JSONReporter.new(redundancies).report
        else
          report = Reporter.new(redundancies).report(verbose:@verbose, color:@color)
          puts report unless report.empty?
        end
      end

    rescue Parslet::ParseFailed => e
      line, column = e.cause.source.line_and_column(e.cause.pos)
      puts "Had a problem parsing the css at line: #{line}, column: #{column}".red
      if @show_parser_errors || ENV['CSSCSS_DEBUG'] == 'true'
        puts e.cause.ascii_tree.red
      else
        puts "Run with --show-parser-errors for verbose parser errors".red
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

        opts.on("--[no-]color", "Colorize output (default is #{@color})") do |c|
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

        opts.on("--[no-]compass", "Enable compass extensions when parsing sass/scss (default is false)") do |compass|
          enable_compass if @compass = compass
        end

        opts.on("--compass-with-config config", "Enable compass extensions when parsing sass/scss and pass config file") do |config|
          @compass = true
          enable_compass(config)
        end

        opts.on("--[no-]match-shorthand", "Expands shorthand rules and matches on explicit rules (default is true)") do |match_shorthand|
          @match_shorthand = match_shorthand
        end

        opts.on("-j", "--[no-]json", "Output results in JSON") do |j|
          @json = j
        end

        opts.on("--show-parser-errors", "Print verbose parser errors") do |show_parser_errors|
          @show_parser_errors = show_parser_errors
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

    def warn_old_debug_flag
      $stderr.puts "CSSCSS_DEBUG is now deprecated. Use --show-parser-errors instead".red
    end

    def enable_compass(config = nil)
      require "compass"

      if config
        Compass.add_configuration(config)
      else
        Compass.add_configuration("config.rb") if File.exist?("config.rb")
      end
    rescue LoadError
      abort "Must install compass gem before enabling its extensions"
    end

    def windows_1_9
      RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/ && RUBY_VERSION =~ /^1\.9/
    end

    class << self
      def run(argv)
        new(argv).run
      end
    end
  end
end
