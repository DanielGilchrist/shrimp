module Shrimp
  abstract class Display
    abstract def render
    abstract def width : Int32
    abstract def height : Int32

    getter width : Int32
    getter height : Int32
    getter scale : Int32

    @buffer : Array(Array(UInt8))

    def initialize(@width = 64, @height = 32, @scale = 10)
      @buffer = Array.new(@height) { Array.new(@width, 0_u8) }
    end

    def set_pixel(x : Int32, y : Int32, value : UInt8)
      return if x < 0 || x >= @width || y < 0 || y >= @height

      @buffer[y][x] = value
    end

    def get_pixel(x : Int32, y : Int32) : UInt8
      return 0_u8 if x < 0 || x >= @width || y < 0 || y >= @height

      @buffer[y][x]
    end

    def clear
      @buffer.each(&.fill(0_u8))
    end
  end
end
