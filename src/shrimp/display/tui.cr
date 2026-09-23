require "../display"

module Shrimp
  class Display
    class TUI < Display
      GLYPHS = {" ", "▀", "▄", "█"}

      HOME_CURSOR  = "\e[H"
      CLEAR_SCREEN = "\e[2J"
      CLEAR_LINE   = "\e[K"

      LOG_LINES = 8

      KEY_CTRL_C = 0x03_u8
      KEY_QUIT   = 'q'.ord.to_u8

      getter required_size : Size

      @keys : Channel(UInt8)
      @log : Deque(String)
      @terminal_size : Size?

      def initialize(
        @input : IO = STDIN,
        @output : IO = STDOUT,
        @terminal_size : Size? = Terminal.size(STDOUT),
        @width : Int32 = 64,
        @height : Int32 = 32,
        @scale : Int32 = 1,
      ) : Nil
        @keys = Channel(UInt8).new(64)
        @log = Deque(String).new(LOG_LINES)
        @required_size = Size.new(@width, @height // 2)

        Terminal.enter(@input, @output)
        at_exit { Terminal.leave(@input, @output) }
        watch_for_resize
        spawn { read_keys }

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

        @output.print frame
        @output.flush
      end

      def poll_events : Bool
        loop do
          select
          when key = @keys.receive
            return false if quit_key?(key)
          else
            return true
          end
        end
      end

      def log(message : String) : Nil
        @log.shift if @log.size == LOG_LINES
        @log.push(message)
        mark_dirty
      end

      def resize(@terminal_size : Size?) : Nil
        @output.print CLEAR_SCREEN
        mark_dirty
      end

      private def watch_for_resize : Nil
        return unless Terminal.tty?(@output)

        Signal::WINCH.trap { resize(Terminal.size(@output)) }
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

      private def render_too_small(io : IO, size : Size) : Nil
        io << CLEAR_LINE << "Terminal is " << size << ", at least " << @required_size << " is required"
      end

      private def quit_key?(key : UInt8) : Bool
        key.in?(KEY_CTRL_C, KEY_QUIT)
      end

      private def read_keys : Nil
        while byte = @input.read_byte
          @keys.send(byte)
        end
      end
    end
  end
end

require "./tui/size"
require "./tui/terminal"
