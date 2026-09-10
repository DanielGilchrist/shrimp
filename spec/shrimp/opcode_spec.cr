require "../spec_helper"

describe Shrimp::Opcode do
  describe ".from" do
    it "combines two bytes into a big endian opcode" do
      Shrimp::Opcode.from(Bytes[0xA2, 0xF0], 0_u16).to_s.should eq("0xA2F0")
    end

    it "reads from the given index" do
      Shrimp::Opcode.from(Bytes[0x00, 0x00, 0x12, 0x34], 2_u16).to_s.should eq("0x1234")
    end
  end

  describe "nibble accessors" do
    opcode = Shrimp::Opcode.new(0xD123_u16)

    it "extracts the instruction type" do
      opcode.instruction_type.should eq(0xD)
    end

    it "extracts vx" do
      opcode.vx.should eq(0x1)
    end

    it "extracts vy" do
      opcode.vy.should eq(0x2)
    end

    it "extracts the lowest nibble" do
      opcode.lowest_nibble.should eq(0x3)
    end

    it "extracts the address" do
      opcode.address.should eq(0x123)
    end

    it "extracts the immediate value" do
      opcode.immediate_value.should eq(0x23)
    end
  end

  describe "#to_s" do
    it "zero pads to four hex digits" do
      Shrimp::Opcode.new(0x00E0_u16).to_s.should eq("0x00E0")
    end
  end
end
