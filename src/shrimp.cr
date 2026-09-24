require "kebab"

require "./shrimp/key"
require "./shrimp/keypad"
require "./shrimp/interpreter"
require "./shrimp/display"
require "./shrimp/cli"

module Shrimp
  extend self

  VERSION        = "0.1.0"
  FRAME_DURATION = Time::Span.new(nanoseconds: 1_000_000_000 // 60)

  def main(display : Display.class, input : Input.class) : Nil
    case cli = CLI.parse(ARGV)
    in CLI
      run(cli, display.new, input.new)
    in Kebab::Help
      STDOUT.puts cli
    in Kebab::Errors
      STDERR.puts cli
      exit(1)
    end
  end

  private def run(cli : CLI, display : Display, input : Input) : Nil
    display.log("Starting interpreter...")

    keypad = Keypad.new
    interpreter = Interpreter.new(display, keypad)
    interpreter.trace = cli.trace?
    rom_bytes = File.read(cli.rom, encoding: nil).to_slice
    interpreter.load_rom(rom_bytes)

    display.log("Successfully loaded #{cli.rom}")

    main_loop(interpreter, input, keypad)

    STDOUT.puts "Exiting..."
  end

  private def main_loop(
    interpreter : Interpreter,
    input : Input,
    keypad : Keypad,
  ) : Nil
    unimplemented_instruction = false

    loop do
      frame_start = Time.instant
      return unless input.poll(keypad)

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
