require "spec"
require "../src/shrimp"
require "./support/test_display"

def rom_for(opcodes : Enumerable(UInt16)) : Bytes
  bytes = Bytes.new(opcodes.size * 2)

  opcodes.each_with_index do |opcode, i|
    bytes[i * 2] = (opcode >> 8).to_u8
    bytes[i * 2 + 1] = (opcode & 0xFF).to_u8
  end

  bytes
end

def interpreter_for(opcodes : Enumerable(UInt16), display : Shrimp::Display, keypad : Shrimp::Keypad = Shrimp::Keypad.new) : Shrimp::Interpreter
  interpreter = Shrimp::Interpreter.new(display, keypad)
  interpreter.load_rom(rom_for(opcodes))

  interpreter
end
