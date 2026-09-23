class TestDisplay < Shrimp::Display
  getter render_count : Int32 = 0

  def render : Nil
    @render_count += 1
  end

  def poll_events : Bool
    true
  end

  def lit_pixels : Array({Int32, Int32})
    coordinates = [] of {Int32, Int32}

    height.times do |y|
      width.times do |x|
        coordinates << {x, y} if get_pixel(x, y) == 1
      end
    end

    coordinates
  end
end
