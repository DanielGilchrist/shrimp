module Shrimp
  abstract class Display
    abstract def render : Nil
    abstract def poll_events : Bool
    abstract def width : Int32
    abstract def height : Int32

    getter width : Int32
    getter height : Int32
    getter scale : Int32

    @buffer : Array(Array(UInt8))
    @dirty = true

    def initialize(@width : Int32 = 64, @height : Int32 = 32, @scale : Int32 = 10) : Nil
      @buffer = Array.new(@height) { Array.new(@width, 0_u8) }
    end

    def present : Nil
      return unless @dirty

      render
      @dirty = false
    end

    def set_pixel(x : Int32, y : Int32, value : UInt8) : Nil
      return if x < 0 || x >= @width || y < 0 || y >= @height
      return if @buffer[y][x] == value

      @buffer[y][x] = value
      mark_dirty
    end

    def get_pixel(x : Int32, y : Int32) : UInt8
      return 0_u8 if x < 0 || x >= @width || y < 0 || y >= @height

      @buffer[y][x]
    end

    def clear : Nil
      @buffer.each(&.fill(0_u8))
      mark_dirty
    end

    def log(message : String) : Nil
      STDERR.puts message
    end

    protected def mark_dirty : Nil
      @dirty = true
    end
  end
end
