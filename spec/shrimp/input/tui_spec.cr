require "../../spec_helper"
require "../../../src/shrimp/input/tui"

private def tui_input_for(bytes : String) : Shrimp::Input::TUI
  terminal = Shrimp::Terminal.new(IO::Memory.new(bytes), IO::Memory.new)
  input = Shrimp::Input::TUI.new(terminal)
  Fiber.yield

  input
end

describe Shrimp::Input::TUI do
  describe "#poll" do
    it "continues when nothing was typed" do
      tui_input_for("").poll(Shrimp::Keypad.new).should be_true
    end

    it "continues on unmapped bytes" do
      keypad = Shrimp::Keypad.new

      tui_input_for("p").poll(keypad).should be_true

      Shrimp::Key.each { |key| keypad.pressed?(key).should be_false }
    end

    it "presses the mapped key" do
      keypad = Shrimp::Keypad.new

      tui_input_for("w").poll(keypad).should be_true

      keypad.pressed?(Shrimp::Key::Five).should be_true
    end

    it "holds the key until the hold period expires" do
      keypad = Shrimp::Keypad.new
      input = tui_input_for("w")

      input.poll(keypad)
      (Shrimp::Input::TUI::HOLD_FRAMES - 2).times { input.poll(keypad) }
      keypad.pressed?(Shrimp::Key::Five).should be_true

      input.poll(keypad)
      keypad.pressed?(Shrimp::Key::Five).should be_false
    end

    it "quits on ctrl-c" do
      tui_input_for("").poll(Shrimp::Keypad.new).should be_false
    end
  end
end
