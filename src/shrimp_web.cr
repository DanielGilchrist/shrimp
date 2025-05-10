require "base64"
require "js"
require "web"
require "./shrimp/interpreter"
require "./shrimp/display/canvas"

class String
  # This constant is required by crystal-js
  # The value is arbitrary but must be unique
  TYPE_ID = 0x1234_5678
end

module Web
  class HTMLCanvasElement < HTMLElement
    js_getter width : Int32
    js_getter height : Int32
    js_setter width : Int32
    js_setter height : Int32
    js_method setAttribute(name : String, value : String)
    js_method getContext(name : String), CanvasContext
  end

  class CanvasContext
    js_setter fillStyle : String
    js_method fillRect(x : Int32, y : Int32, width : Int32, height : Int32)
  end
end

module GlobalState
  @@interpreter : Shrimp::Interpreter? = nil

  def self.interpreter
    @@interpreter
  end

  def self.interpreter=(value)
    @@interpreter = value
  end
end

JS.export def init_interpreter(rom_data : String) : Bool
  rom_bytes = Base64.decode(rom_data)
  display = Shrimp::Display::Canvas.new
  interpreter = Shrimp::Interpreter.new(display)
  interpreter.load_rom(rom_bytes)

  GlobalState.interpreter = interpreter

  true
end

JS.export def cycle_interpreter : Bool
  interpreter = GlobalState.interpreter
  return false unless interpreter

  interpreter.cycle
  true
end
