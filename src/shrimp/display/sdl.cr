require "../display"

module Shrimp
  class Display
    class SDL < Display
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

        super
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
