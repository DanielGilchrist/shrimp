require "../../spec_helper"
require "../../../src/shrimp/display/tui"

private def tui_for(input : String = "", size : Shrimp::Display::TUI::Size? = nil) : {Shrimp::Display::TUI, IO::Memory}
  output = IO::Memory.new
  tui = Shrimp::Display::TUI.new(IO::Memory.new(input), output, size)
  output.clear

  {tui, output}
end

private def frame_rows(output : IO::Memory) : Array(String)
  output.to_s.lchop(Shrimp::Display::TUI::HOME_CURSOR).split("\r\n")
end

describe Shrimp::Display::TUI do
  describe "#render" do
    it "renders two pixel rows per line using half blocks" do
      tui, output = tui_for
      tui.set_pixel(0, 0, 1_u8)
      tui.set_pixel(1, 1, 1_u8)
      tui.set_pixel(2, 0, 1_u8)
      tui.set_pixel(2, 1, 1_u8)

      tui.render

      rows = frame_rows(output)
      rows.size.should eq(16)
      rows[0][0, 4].should eq("▀▄█ ")
    end

    it "does not end the frame with a newline" do
      tui, output = tui_for
      tui.log("last")

      tui.render

      output.to_s.should_not end_with("\r\n")
    end

    it "renders an empty display as blank rows" do
      tui, output = tui_for

      tui.render

      rows = frame_rows(output)[0, 16]
      rows.each(&.should(eq(" " * 64)))
    end

    it "renders a log panel below the display" do
      tui, output = tui_for
      tui.log("hello")

      tui.render

      rows = frame_rows(output)
      rows[16].should eq("─" * 64)
      rows[17].should eq("#{Shrimp::Display::TUI::CLEAR_LINE}hello")
    end

    it "keeps only the most recent log lines" do
      tui, output = tui_for
      10.times { |i| tui.log("line #{i}") }

      tui.render

      rows = frame_rows(output)
      rows[17].should contain("line 2")
      rows[24].should contain("line 9")
    end

    it "shrinks the log panel to the rows available" do
      tui, output = tui_for(size: Shrimp::Display::TUI::Size.new(64, 19))
      5.times { |i| tui.log("line #{i}") }

      tui.render

      rows = frame_rows(output)
      rows[16].should eq("─" * 64)
      rows[17].should contain("line 3")
      rows[18].should contain("line 4")
      rows.size.should eq(19)
    end

    it "omits the log panel when only the display fits" do
      tui, output = tui_for(size: Shrimp::Display::TUI::Size.new(64, 16))
      tui.log("hidden")

      tui.render

      output.to_s.should_not contain("hidden")
      frame_rows(output).size.should eq(16)
    end

    it "renders a message instead of the display when the terminal is too small" do
      tui, output = tui_for(size: Shrimp::Display::TUI::Size.new(64, 15))

      tui.render

      output.to_s.should contain("Terminal is 64x15, at least 64x16 is required")
    end

    it "renders the display again once the terminal grows" do
      tui, output = tui_for(size: Shrimp::Display::TUI::Size.new(40, 10))
      tui.resize(Shrimp::Display::TUI::Size.new(64, 16))
      output.clear

      tui.render

      frame_rows(output).size.should eq(16)
    end
  end

  describe "#poll_events" do
    it "continues when no keys were pressed" do
      tui, _ = tui_for
      Fiber.yield

      tui.poll_events.should be_true
    end

    it "continues on unrelated keys" do
      tui, _ = tui_for("abc")
      Fiber.yield

      tui.poll_events.should be_true
    end

    it "continues on arrow key and scroll escape sequences" do
      tui, _ = tui_for("\e[A\e[B")
      Fiber.yield

      tui.poll_events.should be_true
    end

    {"q" => "q", "" => "ctrl-c"}.each do |key, name|
      it "quits on #{name}" do
        tui, _ = tui_for(key)
        Fiber.yield

        tui.poll_events.should be_false
      end
    end
  end
end
