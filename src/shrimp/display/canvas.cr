require "../display"

module Shrimp
  class Display
    class Canvas < Display

      @canvas : Web::HTMLCanvasElement
      @ctx : Web::CanvasContext

      def initialize(@width = 64, @height = 32, @scale = 10)
        document = Web.window.document

        @canvas = document.create_element("canvas")
        @canvas.width = (@width * @scale)
        @canvas.height = (@height * @scale)
        @canvas.set_attribute("style", "background-color: black;")

        document.body.append_child(@canvas)

        @ctx = @canvas.get_context("2d")

        super
      end

      def render
        @ctx.fill_style = "black"
        @ctx.fill_rect(0, 0, @width * @scale, @height * @scale)

        @ctx.fill_style = "white"

        @height.times do |y|
          @width.times do |x|
            next if @buffer[y][x] != 1

            @ctx.fill_rect(
              x * @scale,
              y * @scale,
              @scale,
              @scale
            )
          end
        end
      end
    end
  end
end
