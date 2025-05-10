module Shrimp
  abstract class Display
    abstract def clear
    abstract def set_pixel(x : Int32, y : Int32, value : UInt8)
    abstract def get_pixel(x : Int32, y : Int32) : UInt8
    abstract def render
    abstract def width : Int32
    abstract def height : Int32
  end
end
