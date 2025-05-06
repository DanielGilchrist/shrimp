module Shrimp
  class Interpreter
    ROM_START_ADDRESS = 0x200_u16
    MEMORY_SIZE       =      4096

    FONTSET = Bytes[
      0xF0, 0x90, 0x90, 0x90, 0xF0, # 0
      0x20, 0x60, 0x20, 0x20, 0x70, # 1
      0xF0, 0x10, 0xF0, 0x80, 0xF0, # 2
      0xF0, 0x10, 0xF0, 0x10, 0xF0, # 3
      0x90, 0x90, 0xF0, 0x10, 0x10, # 4
      0xF0, 0x80, 0xF0, 0x10, 0xF0, # 5
      0xF0, 0x80, 0xF0, 0x90, 0xF0, # 6
      0xF0, 0x10, 0x20, 0x40, 0x40, # 7
      0xF0, 0x90, 0xF0, 0x90, 0xF0, # 8
      0xF0, 0x90, 0xF0, 0x10, 0xF0, # 9
      0xF0, 0x90, 0xF0, 0x90, 0x90, # A
      0xE0, 0x90, 0xE0, 0x90, 0xE0, # B
      0xF0, 0x80, 0x80, 0x80, 0xF0, # C
      0xE0, 0x90, 0x90, 0x90, 0xE0, # D
      0xF0, 0x80, 0xF0, 0x80, 0xF0, # E
      0xF0, 0x80, 0xF0, 0x80, 0x80  # F
    ]
    FONTSET_START_ADDRESS = 0x50_u16

    alias Instruction = Proc(UInt16, Nil)

    @display : Array(Array(UInt8))

    @table : Array(Instruction)
    @table0 : Array(Instruction)
    @table8 : Array(Instruction)
    @tableE : Array(Instruction)
    @tableF : Array(Instruction)

    def initialize
      @memory = Bytes.new(MEMORY_SIZE, 0)
      @registers = Bytes.new(16, 0)
      @index = 0_u16
      @pc = ROM_START_ADDRESS
      @stack = Array(UInt16).new(16, 0)
      @sp = 0_u8
      @delay_timer = 0_u8
      @sound_timer = 0_u8
      @keypad = Bytes.new(16, 0)
      @display = Array.new(32) { Array(UInt8).new(64, 0) }

      @table0 = [
        clear_screen,
        return_from_subroutine,
      ]

      @table8 = [] of Instruction
      @tableE = [] of Instruction
      @tableF = [] of Instruction

      @table = [
        Instruction.new { |opcode| @table0[opcode & 0x000F].call(opcode) },
        jump,
        call,
        skip_if_register_equals_value,
        skip_if_register_not_equals_value,
        skip_if_registers_equal,
        load_register_with_value,
        # ...
      ]

      load_fonts
    end

    def load_rom(filename : String)
      File.read(filename, encoding: nil).to_slice.each_with_index do |byte, i|
        @memory[ROM_START_ADDRESS + i] = byte if (ROM_START_ADDRESS + i) < MEMORY_SIZE
      end
    end

    def cycle
      opcode = (@memory[@pc].to_u16 << 8) | @memory[@pc + 1].to_u16
      @pc += 2

      execute(opcode)

      if @delay_timer > 0
        @delay_timer -= 1
      end

      if @sound_timer > 0
        @sound_timer -= 1
      end
    end

    private def load_fonts
      FONTSET.each_with_index do |byte, i|
        @memory[FONTSET_START_ADDRESS + i] = byte
      end
    end

    private def execute(opcode : UInt16)
      idx = (opcode & 0xF000) >> 12

      {% if flag?(:debug) %}
        instruction = @table[idx]?
        pretty_opcode = "0x#{opcode.to_s(16).upcase.rjust(4, '0')}"

        if instruction
          puts pretty_opcode
          instruction.call(opcode)
        else
          raise(NotImplementedError.new("opcode #{pretty_opcode}"))
        end
      {% else %}
        @table[idx].call(opcode)
      {% end %}
    end

    # 0x00E0: CLS
    private def clear_screen : Instruction
      Instruction.new { @display.each(&.fill(0)) }
    end

    # 0x00EE: RET
    private def return_from_subroutine : Instruction
      Instruction.new do
        @sp -= 1
        @pc = @stack[@sp]
      end
    end

    # 0x1NNN: JP addr
    private def jump : Instruction
      Instruction.new { |opcode| @pc = opcode & 0x0FFF }
    end

    # 0x2NNN: CALL addr
    private def call : Instruction
      Instruction.new do |opcode|
        address = opcode & 0x0FFF

        @stack[@sp] = @pc
        @sp += 1
        @pc = address
      end
    end

    # 0x3XKK: SE Vx, byte
    private def skip_if_register_equals_value : Instruction
      Instruction.new do |opcode|
        vx = (opcode & 0x0F00) >> 8
        byte = opcode & 0x00FF

        if @registers[vx] == byte
          @pc += 2
        end
      end
    end

    # 0x4XKK: SNE Vx, byte
    private def skip_if_register_not_equals_value : Instruction
      Instruction.new do |opcode|
        vx = (opcode & 0x0F00) >> 8
        byte = opcode & 0x00FF

        if @registers[vx] != byte
          @pc += 2
        end
      end
    end

    # 0x5XY0: SE Vx, Vy
    private def skip_if_registers_equal : Instruction
      Instruction.new do |opcode|
        vx = (opcode & 0x0F00) >> 8
        vy = (opcode & 0x00F0) >> 4

        if @registers[vx] == @registers[vy]
          @pc += 2
        end
      end
    end

    # 0x6XKK: LD Vx, byte
    private def load_register_with_value : Instruction
      Instruction.new do |opcode|
        vx = (opcode & 0x0F00) >> 8
        byte = opcode & 0x00FF

        @registers[vx] = byte.to_u8
      end
    end
  end
end
