require "../spec_helper"

describe Shrimp::Keypad do
  it "starts with every key released" do
    keypad = Shrimp::Keypad.new

    Shrimp::Key.each { |key| keypad.pressed?(key).should be_false }
  end

  it "tracks a press and a release" do
    keypad = Shrimp::Keypad.new

    keypad.press(Shrimp::Key::A)
    keypad.pressed?(Shrimp::Key::A).should be_true
    keypad.not_pressed?(Shrimp::Key::A).should be_false

    keypad.release(Shrimp::Key::A)
    keypad.pressed?(Shrimp::Key::A).should be_false
    keypad.not_pressed?(Shrimp::Key::A).should be_true
  end

  it "holds keys independently" do
    keypad = Shrimp::Keypad.new

    keypad.press(Shrimp::Key::Two)
    keypad.press(Shrimp::Key::Three)
    keypad.release(Shrimp::Key::Two)

    keypad.pressed?(Shrimp::Key::Two).should be_false
    keypad.pressed?(Shrimp::Key::Three).should be_true
  end
end
