require "./shrimp/**"

module Shrimp
  extend self

  VERSION = "0.1.0"

  def main
    interpreter = Interpreter.new
    interpreter.load_rom(String.new)

    loop do
      interpreter.cycle
    end
  end
end

Shrimp.main
