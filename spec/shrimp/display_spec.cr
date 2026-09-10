require "../spec_helper"

describe Shrimp::Display do
  describe "#initialize" do
    it "defaults to a 64x32 display" do
      display = TestDisplay.new

      display.width.should eq(64)
      display.height.should eq(32)
      display.scale.should eq(10)
    end
  end

  describe "#set_pixel" do
    it "stores the value at the given coordinates" do
      display = TestDisplay.new
      display.set_pixel(3, 4, 1_u8)

      display.get_pixel(3, 4).should eq(1_u8)
    end

    it "ignores coordinates outside the display" do
      display = TestDisplay.new

      display.set_pixel(-1, 0, 1_u8)
      display.set_pixel(0, -1, 1_u8)
      display.set_pixel(display.width, 0, 1_u8)
      display.set_pixel(0, display.height, 1_u8)

      display.lit_pixels.should be_empty
    end
  end

  describe "#get_pixel" do
    it "returns zero for coordinates outside the display" do
      display = TestDisplay.new

      display.get_pixel(-1, 0).should eq(0_u8)
      display.get_pixel(display.width, display.height).should eq(0_u8)
    end
  end

  describe "#clear" do
    it "resets every pixel" do
      display = TestDisplay.new
      display.set_pixel(0, 0, 1_u8)
      display.set_pixel(10, 20, 1_u8)

      display.clear

      display.lit_pixels.should be_empty
    end
  end
end
