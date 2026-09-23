require "io/console"

require "./terminal/lib_c"
require "./terminal/size"

module Shrimp
  module Terminal
    extend self

    ENTER_SCREEN = "\e[?1049h\e[?25l\e[2J"
    LEAVE_SCREEN = "\e[?25h\e[?1049l"

    def tty?(io : IO) : Bool
      io.is_a?(IO::FileDescriptor) && io.tty?
    end

    def size(io : IO) : Size?
      return unless io.is_a?(IO::FileDescriptor) && io.tty?

      winsize = uninitialized LibC::Winsize
      return if LibC.ioctl(io.fd, LibC::TIOCGWINSZ, pointerof(winsize)) == -1
      return if winsize.ws_col == 0 || winsize.ws_row == 0

      Size.new(winsize.ws_col.to_i32, winsize.ws_row.to_i32)
    end

    def enter(input : IO, output : IO) : Nil
      input.raw! if input.is_a?(IO::FileDescriptor) && input.tty?
      output.print ENTER_SCREEN
      output.flush
    end

    def leave(input : IO, output : IO) : Nil
      output.print LEAVE_SCREEN
      output.flush
      input.cooked! if input.is_a?(IO::FileDescriptor) && input.tty?
    end
  end
end
