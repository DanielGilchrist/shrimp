require "../display"
require "../terminal"

module Shrimp
  class Display
    class TUI < Display
      GLYPHS = {" ", "▀", "▄", "█"}

      HOME_CURSOR  = "\e[H"
      CLEAR_SCREEN = "\e[2J"
      CLEAR_LINE   = "\e[K"

      LOG_LINES = 8

      getter required_size : Terminal::Size

      def initialize(
        @terminal : Terminal = Terminal.stdio,
        terminal_size : Terminal::Size? = nil,
        @width : Int32 = 64,
        @height : Int32 = 32,
        @scale : Int32 = 1,
      ) : Nil
        @log = Deque(String).new(LOG_LINES)
        @required_size = Terminal::Size.new(@width, @height // 2)
        @terminal_size = terminal_size || @terminal.size

        @terminal.open
        @terminal.on_resize { |size| resize(size) }

        super(@width, @height, @scale)
      end

      def render : Nil
        frame = String.build do |io|
          io << HOME_CURSOR

          if (size = @terminal_size) && !size.fits?(@required_size)
            render_too_small(io, size)
          else
            (pixel_lines + log_lines).join(io, "\r\n")
          end
        end

        @terminal.output.print frame
        @terminal.output.flush
      end

      def log(message : String) : Nil
        @log.shift if @log.size == LOG_LINES
        @log.push(message)
        mark_dirty
      end

      def resize(@terminal_size : Terminal::Size?) : Nil
        @terminal.output.print CLEAR_SCREEN
        mark_dirty
      end

      private def pixel_lines : Array(String)
        (0...@height).step(2).to_a.map do |y|
          String.build(@width) do |line|
            @width.times do |x|
              line << GLYPHS[@buffer[y][x] | (@buffer[y + 1][x] << 1)]
            end
          end
        end
      end

      private def log_lines : Array(String)
        lines = visible_log_lines
        return lines if lines.empty?

        ["─" * @width] + lines.map { |line| CLEAR_LINE + line[0, @width] }
      end

      private def visible_log_lines : Array(String)
        size = @terminal_size
        available = size ? size.rows - @required_size.rows - 1 : LOG_LINES
        count = {available, @log.size}.min

        count > 0 ? @log.to_a.last(count) : [] of String
      end

      private def render_too_small(io : IO, size : Terminal::Size) : Nil
        io << CLEAR_LINE << "Terminal is " << size << ", at least " << @required_size << " is required"
      end
    end
  end
end
