require "option_parser"
require "sdl"

require "./shrimp/interpreter"
require "./shrimp/display/sdl"

module Shrimp
  extend self

  VERSION = "0.1.0"

  def main
    display = Display::SDL.new

    STDIN.puts("Starting interpreter...")

    options = parse_options!

    interpreter = Interpreter.new(display)

    rom_bytes = File.read(options.rom_path, encoding: nil).to_slice
    interpreter.load_rom(rom_bytes)

    STDIN.puts("Successfully loaded #{options.rom_path}")

    main_loop(interpreter)

    STDIN.puts("Exiting...")
  end

  private def main_loop(interpreter : Interpreter)
    running = true
    unimplemented_instruction = false

    while running
      while event = ::SDL::Event.poll
        case event
        when ::SDL::Event::Quit
          running = false
        when ::SDL::Event::Keyboard
          if event.sym.escape?
            running = false
          end
        end
      end

      begin
        interpreter.cycle unless unimplemented_instruction
      rescue error : NotImplementedError
        unimplemented_instruction = true
        puts error
      end
    end
  end

  private def parse_options! : Options
    rom_path = ""

    OptionParser.parse do |parser|
      parser.banner = "Usage: shrimp [arguments]"
      parser.on("-r PATH", "--rom=PATH", "Specifies the path to a ROM") { |path| rom_path = path }
      parser.on("-h", "--help", "Show this help") do
        puts parser
        exit
      end

      parser.invalid_option do |flag|
        error!("ERROR: #{flag} is not a valid option.") do
          STDERR.puts parser
        end
      end
    end

    if rom_path.blank?
      error!("--rom must be provided!")
    end

    Options.new(rom_path)
  end

  private def error!(message : String)
    error!(message) { }
  end

  private def error!(message : String, &)
    STDERR.puts(message)
    yield
    exit(1)
  end

  private record Options, rom_path : String
end

Shrimp.main
