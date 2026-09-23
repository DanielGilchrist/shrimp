require "kebab"
require "sdl"

require "./shrimp/interpreter"
require "./shrimp/display/sdl"
require "./shrimp/cli"

module Shrimp
  extend self

  VERSION        = "0.1.0"
  FRAME_DURATION = Time::Span.new(nanoseconds: 1_000_000_000 // 60)

  def main : Nil
    case cli = CLI.parse(ARGV)
    in CLI
      run(cli)
    in Kebab::Help
      STDOUT.puts cli
    in Kebab::Errors
      STDERR.puts cli
      exit(1)
    end
  end

  private def run(cli : CLI) : Nil
    display = Display::SDL.new

    STDOUT.puts "Starting interpreter..."

    interpreter = Interpreter.new(display)
    rom_bytes = File.read(cli.rom, encoding: nil).to_slice
    interpreter.load_rom(rom_bytes)

    STDOUT.puts "Successfully loaded #{cli.rom}"

    main_loop(interpreter)

    STDOUT.puts "Exiting..."
  end

  private def main_loop(interpreter : Interpreter) : Nil
    unimplemented_instruction = false

    loop do
      frame_start = Time.instant

      while event = ::SDL::Event.poll
        case event
        when ::SDL::Event::Quit
          return
        when ::SDL::Event::Keyboard
          if event.sym.escape?
            return
          end
        end
      end

      begin
        interpreter.step unless unimplemented_instruction
      rescue error : NotImplementedError
        unimplemented_instruction = true
        STDERR.puts error
      end

      elapsed = Time.instant - frame_start
      sleep(FRAME_DURATION - elapsed) if elapsed < FRAME_DURATION
    end
  end
end
