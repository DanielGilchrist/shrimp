require "kebab"
require "sdl"

require "./shrimp/interpreter"
require "./shrimp/display/sdl"
require "./shrimp/commands/main"

module Shrimp
  extend self

  VERSION = "0.1.0"

  def main
    case result = Commands::Main.parse(ARGV)
    in Commands::Main then result.run
    in Kebab::Help    then puts result
    in Kebab::Errors  then STDERR.puts(result); exit(1)
    end
  end
end

Shrimp.main
