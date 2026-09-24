require "../spec_helper"

describe Shrimp::Key do
  it "numbers the keys 0x0 to 0xF in keypad order" do
    Shrimp::Key::Zero.value.should eq(0x0_u8)
    Shrimp::Key::Nine.value.should eq(0x9_u8)
    Shrimp::Key::A.value.should eq(0xA_u8)
    Shrimp::Key::F.value.should eq(0xF_u8)
  end

  it "round trips through a register value" do
    Shrimp::Key.from_value(0x5_u8).should eq(Shrimp::Key::Five)
  end

  it "rejects values above 0xF" do
    expect_raises(ArgumentError) { Shrimp::Key.from_value(0x10_u8) }
  end
end
