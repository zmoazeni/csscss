# These are my multibyte optimizations for parslet.
# More information can be found: 
# https://github.com/kschiess/parslet/issues/73
# https://github.com/kschiess/parslet/pull/74
# https://github.com/zmoazeni/parslet/tree/optimized-multibyte-parsing

require 'strscan'
require 'forwardable'

module Parslet
  class Source
    extend Forwardable

    def initialize(str)
      raise ArgumentError unless str.respond_to?(:to_str)

      @str = StringScanner.new(str)

      @line_cache = LineCache.new
      @line_cache.scan_for_line_endings(0, str)
    end

    def matches?(pattern)
      regexp = pattern.is_a?(String) ? Regexp.new(Regexp.escape(pattern)) : pattern
      !@str.match?(regexp).nil?
    end
    alias match matches?

    def consume(n)
      original_pos = @str.pos
      slice_str = n.times.map { @str.getch }.join
      slice = Parslet::Slice.new(
        slice_str,
        original_pos,
        @line_cache)

      return slice
    end

    def chars_left
      @str.rest_size
    end

    def_delegator :@str, :pos
    def pos=(n)
      if n > @str.string.bytesize
        @str.pos = @str.string.bytesize
      else
        @str.pos = n
      end
    end


    class LineCache
      def scan_for_line_endings(start_pos, buf)
        return unless buf

        buf = StringScanner.new(buf)
        return unless buf.exist?(/\n/)

        ## If we have already read part or all of buf, we already know about
        ## line ends in that portion. remove it and correct cur (search index)
        if @last_line_end && start_pos < @last_line_end
          # Let's not search the range from start_pos to last_line_end again.
          buf.pos = @last_line_end - start_pos
        end

        ## Scan the string for line endings; store the positions of all endings
        ## in @line_ends. 
        while buf.skip_until(/\n/)
          @last_line_end = start_pos + buf.pos
          @line_ends << @last_line_end
        end
      end
    end
  end
end
