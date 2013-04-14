require "test_helper.rb"

module Csscss

  def less_gem_installed
    begin
      require "less"
    rescue LoadError
      puts "Less Gem does not appear to be installed. Skipping Less tests"           
      false
    end
    true
  end
  
  describe CLI do 
    it "parses valid less and sass files the same as css files" do
      css_types = []

      css_check = Csscss::CLI.new("filename")
      css_file = css_check.load_css_file("test/csscss/test_input_files/test.css")
      #css_types.push css_file

      if (css_check.gem_installed?('less')) then
        less_check = Csscss::CLI.new("filename")
        less_file = less_check.load_less_file("test/csscss/test_input_files/test.less")     
        css_types.push less_file
      else
        puts "Less not installed, skipping less parsing tests..."
      end

      if (css_check.gem_installed?('sass')) then
        sass_check = Csscss::CLI.new("filename")
        sass_file = sass_check.load_sass_file("test/csscss/test_input_files/test.sass")
        css_types.push sass_file
      else
        puts "Sass not installed, skipping sass parsing tests..."
      end

    end
  end
end
