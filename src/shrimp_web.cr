require "base64"
require "./web_bindings"
require "./shrimp/interpreter"
require "./shrimp/display/canvas"

module GlobalState
  @@interpreter : Shrimp::Interpreter? = nil

  def self.interpreter : Shrimp::Interpreter
    @@interpreter || raise("Interpreter has not been initialised")
  end

  def self.load_rom(rom_data : String) : Nil
    interpreter = Shrimp::Interpreter.new(Shrimp::Display::Canvas.new)
    interpreter.load_rom(Base64.decode(rom_data))

    @@interpreter = interpreter
  end
end

JS.export def init_interpreter(rom_data : String) : Bool
  GlobalState.load_rom(rom_data)

  true
end

JS.export def step_interpreter : Nil
  GlobalState.interpreter.step
end
