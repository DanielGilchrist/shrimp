require "sdl"

module Shrimp
  class Display
    class SDL < Display
      getter width : Int32
      getter height : Int32
      getter scale : Int32

      @window : ::SDL::Window
      @renderer : ::SDL::Renderer
      @texture : ::SDL::Texture
      @buffer : Array(Array(UInt8))

      def initialize(@width = 64, @height = 32, @scale = 10)
        ::SDL.init(::SDL::Init::VIDEO)

        @window = ::SDL::Window.new(
          "Shrimp CHIP-8",
          width: @width * @scale,
          height: @height * @scale
        )

        @renderer = ::SDL::Renderer.new(@window)

        @texture = ::SDL::Texture.new(
          @renderer,
          @width,
          @height,
        )

        @buffer = Array.new(@height) { Array.new(@width, 0_u8) }
      end

      def clear
        @buffer.each(&.fill(0_u8))
      end

      def set_pixel(x : Int32, y : Int32, value : UInt8)
        return if x < 0 || x >= @width || y < 0 || y >= @height

        @buffer[y][x] = value
      end

      def get_pixel(x : Int32, y : Int32) : UInt8
        return 0_u8 if x < 0 || x >= @width || y < 0 || y >= @height

        @buffer[y][x]
      end

      def render
        pixels_data = Array(UInt32).new(@width * @height) do |i|
          y = i // @width
          x = i % @width

          @buffer[y][x] == 0 ? 0x000000FF_u32 : 0xFFFFFFFF_u32
        end

        @texture.lock do |buffer, pitch|
          pixels_data.each_with_index do |pixel, i|
            buffer[i] = pixel
          end
        end

        @renderer.draw_color = ::SDL::Color.new(0, 0, 0, 255)
        @renderer.clear

        @renderer.copy(
          @texture,
          nil,
          ::SDL::Rect.new(0, 0, @width * @scale, @height * @scale)
        )

        @renderer.present
      end

      def finalize
        ::SDL.quit
      end
    end
  end
end
