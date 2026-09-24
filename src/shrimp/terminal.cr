require "io/console"

require "./terminal/lib_c"
require "./terminal/size"

module Shrimp
  class Terminal
    ENTER_SCREEN = "\e[?1049h\e[?25l\e[2J"
    LEAVE_SCREEN = "\e[?25h\e[?1049l"

    @@stdio : Terminal?

    def self.stdio : Terminal
      @@stdio ||= new(STDIN, STDOUT)
    end

    getter input : IO
    getter output : IO

    @open = false

    def initialize(@input : IO = STDIN, @output : IO = STDOUT) : Nil
    end

    def open : Nil
      return if @open

      @open = true
      tty_input.try(&.raw!)
      @output.print ENTER_SCREEN
      @output.flush

      at_exit { close }
    end

    def close : Nil
      return unless @open

      @open = false
      @output.print LEAVE_SCREEN
      @output.flush
      tty_input.try(&.cooked!)
    end

    def size : Size?
      fd = tty_output
      return unless fd

      winsize = uninitialized LibC::Winsize
      return if LibC.ioctl(fd.fd, LibC::TIOCGWINSZ, pointerof(winsize)) == -1
      return if winsize.ws_col == 0 || winsize.ws_row == 0

      Size.new(winsize.ws_col.to_i32, winsize.ws_row.to_i32)
    end

    def on_resize(&handler : Size? ->) : Nil
      return unless tty_output

      Signal::WINCH.trap { handler.call(size) }
    end

    private def tty_input : IO::FileDescriptor?
      tty(@input)
    end

    private def tty_output : IO::FileDescriptor?
      tty(@output)
    end

    private def tty(io : IO) : IO::FileDescriptor?
      io if io.is_a?(IO::FileDescriptor) && io.tty?
    end
  end
end
