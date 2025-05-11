module Shrimp
  struct Opcode
    def self.from(bytes : Bytes, index : UInt16) : Opcode
      new((bytes[index].to_u16 << 8) | bytes[index + 1].to_u16)
    end

    def initialize(@opcode : UInt16)
    end

    def address : UInt16
      @opcode & 0x0FFF
    end

    def immediate_value : UInt16
      @opcode & 0x00FF
    end

    def instruction_type : UInt16
      (@opcode & 0xF000) >> 12
    end

    def lowest_nibble : UInt16
      @opcode & 0x000F
    end

    def vx : UInt16
      (@opcode & 0x0F00) >> 8
    end

    def vy : UInt16
      (@opcode & 0x00F0) >> 4
    end

    def to_s(io)
      io << "0x#{@opcode.to_s(16).upcase.rjust(4, '0')}"
    end
  end
end
