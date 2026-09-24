require "../spec_helper"

describe Shrimp::Interpreter do
  describe "#cycle" do
    it "executes 0x00E0 by clearing the display" do
      display = TestDisplay.new
      display.set_pixel(1, 1, 1_u8)

      interpreter_for([0x00E0_u16], display).cycle

      display.lit_pixels.should be_empty
    end

    it "executes 0xANNN and 0xDXYN by drawing a font sprite" do
      display = TestDisplay.new

      interpreter = interpreter_for([0xA050_u16, 0xD005_u16], display)
      2.times { interpreter.cycle }

      display.lit_pixels.should contain({0, 0})
      display.lit_pixels.should contain({3, 0})
      display.lit_pixels.should_not contain({4, 0})
    end

    it "executes 0x1NNN by jumping to the given address" do
      display = TestDisplay.new

      interpreter = interpreter_for([0x1204_u16, 0xC000_u16, 0x00E0_u16], display)
      display.set_pixel(1, 1, 1_u8)

      2.times { interpreter.cycle }

      display.lit_pixels.should be_empty
    end

    it "raises for an unimplemented opcode" do
      interpreter = interpreter_for([0xC000_u16], TestDisplay.new)

      expect_raises(NotImplementedError) { interpreter.cycle }
    end
  end

  describe "key instructions" do
    it "executes 0xEX9E by skipping when the key in Vx is pressed" do
      display = TestDisplay.new
      display.set_pixel(1, 1, 1_u8)
      keypad = Shrimp::Keypad.new
      keypad.press(Shrimp::Key::Five)

      interpreter = interpreter_for([0x6005_u16, 0xE09E_u16, 0x00E0_u16, 0x6100_u16], display, keypad)
      3.times { interpreter.cycle }

      display.lit_pixels.should eq([{1, 1}])
    end

    it "executes 0xEX9E by continuing when the key in Vx is released" do
      display = TestDisplay.new
      display.set_pixel(1, 1, 1_u8)

      interpreter = interpreter_for([0x6005_u16, 0xE09E_u16, 0x00E0_u16, 0x6100_u16], display)
      3.times { interpreter.cycle }

      display.lit_pixels.should be_empty
    end

    it "executes 0xEXA1 by skipping when the key in Vx is released" do
      display = TestDisplay.new
      display.set_pixel(1, 1, 1_u8)

      interpreter = interpreter_for([0x6005_u16, 0xE0A1_u16, 0x00E0_u16, 0x6100_u16], display)
      3.times { interpreter.cycle }

      display.lit_pixels.should eq([{1, 1}])
    end

    it "executes 0xEXA1 by continuing when the key in Vx is pressed" do
      display = TestDisplay.new
      display.set_pixel(1, 1, 1_u8)
      keypad = Shrimp::Keypad.new
      keypad.press(Shrimp::Key::Five)

      interpreter = interpreter_for([0x6005_u16, 0xE0A1_u16, 0x00E0_u16, 0x6100_u16], display, keypad)
      3.times { interpreter.cycle }

      display.lit_pixels.should be_empty
    end
  end

  describe "#step" do
    it "renders once per frame" do
      display = TestDisplay.new
      interpreter_for(Array.new(Shrimp::Interpreter::CYCLES_PER_FRAME, 0x00E0_u16), display).step

      display.render_count.should eq(1)
    end
  end

  describe "#load_rom" do
    it "ignores bytes that overflow memory" do
      display = TestDisplay.new
      interpreter = Shrimp::Interpreter.new(display, Shrimp::Keypad.new)

      interpreter.load_rom(Bytes.new(Shrimp::Interpreter::MEMORY_SIZE, 0xE0))

      interpreter.cycle
      display.render_count.should eq(0)
    end
  end
end
