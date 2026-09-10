require "js"
require "web"

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
