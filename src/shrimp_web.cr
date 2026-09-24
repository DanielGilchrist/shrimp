require "base64"
require "./web_bindings"
require "./shrimp/interpreter"
require "./shrimp/keypad"
require "./shrimp/display/canvas"

module GlobalState
  @@interpreter : Shrimp::Interpreter? = nil
  @@keypad : Shrimp::Keypad? = nil
  @@trace = false

  KEYS = {
    "1" => Shrimp::Key::One,
    "2" => Shrimp::Key::Two,
    "3" => Shrimp::Key::Three,
    "4" => Shrimp::Key::C,
    "q" => Shrimp::Key::Four,
    "w" => Shrimp::Key::Five,
    "e" => Shrimp::Key::Six,
    "r" => Shrimp::Key::D,
    "a" => Shrimp::Key::Seven,
    "s" => Shrimp::Key::Eight,
    "d" => Shrimp::Key::Nine,
    "f" => Shrimp::Key::E,
    "z" => Shrimp::Key::A,
    "x" => Shrimp::Key::Zero,
    "c" => Shrimp::Key::B,
    "v" => Shrimp::Key::F,
  }

  def self.interpreter : Shrimp::Interpreter
    @@interpreter || uninitialised_global!("interpreter")
  end

  def self.keypad : Shrimp::Keypad
    @@keypad || uninitialised_global!("keypad")
  end

  def self.key?(raw_key : String) : Shrimp::Key?
    KEYS[raw_key]?
  end

  def self.trace=(enabled : Bool) : Nil
    @@trace = enabled
    @@interpreter.try(&.trace=(enabled))
  end

  def self.load_rom(rom_data : String) : Nil
    keypad = Shrimp::Keypad.new
    interpreter = Shrimp::Interpreter.new(Shrimp::Display::Canvas.new, keypad)
    interpreter.trace = @@trace
    interpreter.load_rom(Base64.decode(rom_data))

    @@interpreter = interpreter
    @@keypad = keypad
  end

  private def self.uninitialised_global!(name : String) : NoReturn
    raise("#{name} has not been initialised!")
  end
end

JS.export def init_interpreter(rom_data : String) : Bool
  GlobalState.load_rom(rom_data)

  true
end

JS.export def step_interpreter : Nil
  GlobalState.interpreter.step
end

JS.export def key_down(raw_key : String) : Nil
  if key = GlobalState.key?(raw_key)
    GlobalState.keypad.press(key)
  end
end

JS.export def key_up(raw_key : String) : Nil
  if key = GlobalState.key?(raw_key)
    GlobalState.keypad.release(key)
  end
end

JS.export def set_trace(enabled : Bool) : Nil
  GlobalState.trace = enabled
end
