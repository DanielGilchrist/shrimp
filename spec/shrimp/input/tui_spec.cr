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

    it "continues on unrelated bytes" do
      tui_input_for("abc").poll(Shrimp::Keypad.new).should be_true
    end

    it "quits on q" do
      tui_input_for("q").poll(Shrimp::Keypad.new).should be_false
    end

    it "quits on ctrl-c" do
      tui_input_for("").poll(Shrimp::Keypad.new).should be_false
    end
  end
end
