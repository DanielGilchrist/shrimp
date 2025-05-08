require "option_parser"
require "./shrimp/**"

module Shrimp
  extend self

  VERSION = "0.1.0"

  def main
    options = parse_options!

    interpreter = Interpreter.new
    interpreter.load_rom(options.rom_path)

    loop do
      interpreter.cycle
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
    error!(message) {}
  end

  private def error!(message : String, &)
    STDERR.puts(message)
    yield
    exit(1)
  end

  private record Options, rom_path : String
end

Shrimp.main
