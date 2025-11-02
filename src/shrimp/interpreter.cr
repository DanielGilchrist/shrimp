require "./opcode"

module Shrimp
  class Interpreter
    ROM_START_ADDRESS = 0x200_u16
    MEMORY_SIZE       =      4096
    REGISTER_CAP      = 255_u8 # 8 bits

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

    alias Instruction = Proc(Opcode, Nil)

    @table : Array(Instruction)
    @table0 : Array(Instruction)
    @table8 : Array(Instruction)
    @tableE : Array(Instruction)
    @tableF : Array(Instruction)

    def initialize(@display : Display)
      @memory = Bytes.new(MEMORY_SIZE, 0)
      @registers = Bytes.new(16, 0)
      @index = 0_u16
      @pc = ROM_START_ADDRESS
      @stack = Array(UInt16).new(16, 0)
      @sp = 0_u8
      @delay_timer = 0_u8
      @sound_timer = 0_u8
      @keypad = Bytes.new(16, 0)

      @table0, @table8, @tableE = 3.times.map { Array.new(0xE + 1) { no_op } }.to_a
      @tableF = Array.new(0x65 + 1) { no_op }

      @table0[0x0] = clear_screen
      @table0[0xE] = return_from_subroutine

      @table8[0x0] = set_equal
      @table8[0x1] = bitewise_or
      @table8[0x2] = bitwise_and
      @table8[0x3] = bitwise_xor
      @table8[0x4] = add
      @table8[0x5] = subtract_vy_from_vx
      @table8[0x6] = shift_right
      @table8[0x7] = subtract_vx_from_vy
      @table8[0xE] = shift_left

      @tableE[0x1] = unimplemented(subinstruction: true)
      @tableE[0xE] = unimplemented(subinstruction: true)

      @tableF[0x05] = unimplemented(subinstruction: true)
      @tableF[0x07] = unimplemented(subinstruction: true)
      @tableF[0x0A] = unimplemented(subinstruction: true)
      @tableF[0x15] = unimplemented(subinstruction: true)
      @tableF[0x18] = unimplemented(subinstruction: true)
      @tableF[0x1E] = add_to_index
      @tableF[0x29] = unimplemented(subinstruction: true)
      @tableF[0x33] = load_binary_coded_decimal_to_memory
      @tableF[0x55] = load_to_memory_from_registers
      @tableF[0x65] = load_to_registers_from_memory

      @table = [
        instruction_from(@table0, &.lowest_nibble),
        jump,
        call,
        skip_if_register_equals_value,
        skip_if_register_not_equals_value,
        skip_if_registers_equal,
        load_register_with_value,
        add_register_with_value,
        instruction_from(@table8, &.lowest_nibble),
        skip_if_registers_not_equal,
        set_index,
        unimplemented,
        unimplemented,
        draw_sprite,
        instruction_from(@tableE, &.lowest_nibble),
        instruction_from(@tableF, &.immediate_value)
      ]

      load_fonts
    end

    def load_rom(bytes : Bytes)
      bytes.each_with_index do |byte, i|
        @memory[ROM_START_ADDRESS + i] = byte if (ROM_START_ADDRESS + i) < MEMORY_SIZE
      end
    end

    def cycle
      opcode = Opcode.from(@memory, @pc)
      @pc += 2

      execute(opcode)

      if @delay_timer > 0
        @delay_timer -= 1
      end

      if @sound_timer > 0
        @sound_timer -= 1
      end
    end

    def render
      @display.render
    end

    # TODO: Remove this once all instructions are implemented
    private def unimplemented(subinstruction : Bool = false) : Instruction
      Instruction.new do |opcode|
        idx = opcode.instruction_type
        idx = "#{idx} -> #{opcode.lowest_nibble}" if subinstruction
        raise(NotImplementedError.new("opcode #{opcode} | index: #{idx}"))
      end
    end

    def instruction_from(table : Array(Instruction), &block : Opcode -> UInt16) : Instruction
      Instruction.new { |opcode| table[block.call(opcode)].call(opcode) }
    end

    private def load_fonts
      FONTSET.each_with_index do |byte, i|
        @memory[FONTSET_START_ADDRESS + i] = byte
      end
    end

    private def execute(opcode : Opcode)
      idx = opcode.instruction_type

      {% if flag?(:debug) %}
        puts opcode
        instruction = @table[idx]?

        if instruction
          instruction.call(opcode)
        else
          unimplemented.call(opcode)
        end
      {% else %}
        @table[idx].call(opcode)
      {% end %}
    end

    private def no_op : Instruction
      Instruction.new {}
    end

    # 0x00E0: CLS
    private def clear_screen : Instruction
      Instruction.new { @display.clear }
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
      Instruction.new { |opcode| @pc = opcode.address }
    end

    # 0x2NNN: CALL addr
    private def call : Instruction
      Instruction.new do |opcode|
        @stack[@sp] = @pc
        @sp += 1
        @pc = opcode.address
      end
    end

    # 0x3XKK: SE Vx, byte
    private def skip_if_register_equals_value : Instruction
      Instruction.new do |opcode|
        vx = opcode.vx
        byte = opcode.immediate_value

        if @registers[vx] == byte
          @pc += 2
        end
      end
    end

    # 0x4XKK: SNE Vx, byte
    private def skip_if_register_not_equals_value : Instruction
      Instruction.new do |opcode|
        vx = opcode.vx
        byte = opcode.immediate_value

        if @registers[vx] != byte
          @pc += 2
        end
      end
    end

    # 0x5XY0: SE Vx, Vy
    private def skip_if_registers_equal : Instruction
      Instruction.new do |opcode|
        vx = opcode.vx
        vy = opcode.vy

        if @registers[vx] == @registers[vy]
          @pc += 2
        end
      end
    end

    # 0x6XKK: LD Vx, byte
    private def load_register_with_value : Instruction
      Instruction.new do |opcode|
        vx = opcode.vx
        byte = opcode.immediate_value

        @registers[vx] = byte.to_u8
      end
    end

    # 0x7XKK: ADD Vx, byte
    private def add_register_with_value : Instruction
      Instruction.new do |opcode|
        vx = opcode.vx
        byte = opcode.immediate_value

        @registers[vx] &+= byte.to_u8
      end
    end

    # 0x8XY0: Set Vx, Vy
    private def set_equal : Instruction
      Instruction.new do |opcode|
        vx = opcode.vx
        vy = opcode.vy

        @registers[vx] = @registers[vy]
      end
    end

    # 0x8XY1: OR Vx, Vy
    private def bitewise_or : Instruction
      Instruction.new do |opcode|
        vx = opcode.vx
        vy = opcode.vy

        @registers[vx] |= @registers[vy]
      end
    end

    # 0x8XY2: AND Vx, Vy
    private def bitwise_and : Instruction
      Instruction.new do |opcode|
        vx = opcode.vx
        vy = opcode.vy

        @registers[vx] &= @registers[vy]
      end
    end

    # 0x8XY3: XOR Vx, Vy
    private def bitwise_xor : Instruction
      Instruction.new do |opcode|
        vx = opcode.vx
        vy = opcode.vy

        @registers[vx] ^= @registers[vy]
      end
    end

    # 0x8XY4: ADD Vx, Vy
    private def add : Instruction
      Instruction.new do |opcode|
        vx = opcode.vx
        vy = opcode.vy

        result = @registers[vx].to_u16 + @registers[vy].to_u16

        @registers[0xF] = if result > REGISTER_CAP
          1_u8
        else
          0_u8
        end

        @registers[vx] = (result & 0xFF).to_u8
      end
    end

    # 0x8XY5: SUB Vx, Vy
    private def subtract_vy_from_vx : Instruction
      Instruction.new do |opcode|
        vx = opcode.vx
        vy = opcode.vy

        vx_value = @registers[vx]
        vy_value = @registers[vy]

        if vy > vx
          @registers[0xF] = 1
        else
          @registers[0xF] = 0
        end

        @registers[vx] = vx_value &- vy_value
      end
    end

    # 0x8XY6: SHR Vx, Vy
    private def shift_right : Instruction
      Instruction.new do |opcode|
        vx = opcode.vx
        vy = opcode.vy

        vy_value = @registers[vy]
        @registers[0xF] = vy_value & 0x1
        @registers[vx] = vy_value >> 0x1
      end
    end

    # 0x8XY7: SUBN Vx, Vy
    private def subtract_vx_from_vy : Instruction
      Instruction.new do |opcode|
        vx = opcode.vx
        vy = opcode.vy

        vx_value = @registers[vx]
        vy_value = @registers[vy]

        if vx > vy
          @registers[0xF] = 1
        else
          @registers[0xF] = 0
        end

        @registers[vx] = vy_value &- vx_value
      end
    end

    # 0x8XY6: SH: Vx, Vy
    private def shift_left : Instruction
      Instruction.new do |opcode|
        vx = opcode.vx
        vy = opcode.vy

        vy_value = @registers[vy]
        @registers[0xF] = vy_value | 0x1
        @registers[vx] = vy_value << 0x1
      end
    end

    # 0x9XY0: SNE Vx, Vy
    private def skip_if_registers_not_equal : Instruction
      Instruction.new do |opcode|
        vx = opcode.vx
        vy = opcode.vy

        if @registers[vx] != @registers[vy]
          @pc += 2
        end
      end
    end

    # 0xANNN: LD I, addr
    private def set_index : Instruction
      Instruction.new { |opcode| @index = opcode.address }
    end

    # 0xDXYN: DRW Vx, Vy, nibble
    private def draw_sprite : Instruction
      Instruction.new do |opcode|
        vx = opcode.vx
        vy = opcode.vy
        height = opcode.lowest_nibble

        x_pos = @registers[vx] % @display.width
        y_pos = @registers[vy] % @display.height

        @registers[0xF] = 0

        height.times do |row_index|
          sprite_byte = @memory[@index + row_index]

          8.times do |column_index|
            sprite_pixel = sprite_byte & (0x80 >> column_index)
            next if sprite_pixel == 0

            screen_x = (x_pos + column_index) % @display.width
            screen_y = (y_pos + row_index) % @display.height

            screen_pixel = @display.get_pixel(screen_x, screen_y)
            @registers[0xF] |= screen_pixel

            @display.set_pixel(screen_x, screen_y, screen_pixel ^ 1)
          end
        end
      end
    end

    # 0xFX1E: ADD I, Vx
    private def add_to_index : Instruction
      Instruction.new do |opcode|
        vx = opcode.vx
        @index += @registers[vx]
      end
    end

    # 0xFX33: LD B, Vx
    private def load_binary_coded_decimal_to_memory : Instruction
      Instruction.new do |opcode|
        value = @registers[opcode.vx]
        i = 2

        3.times do
          value, @memory[@index + i] = value.divmod(10)
          i -= 1
        end
      end
    end

    # 0xFX55: LD [I], Vx
    private def load_to_memory_from_registers : Instruction
      Instruction.new do |opcode|
        vx = opcode.vx

        (0..vx).each do |i|
          @memory[@index + i] = @registers[i]
        end
      end
    end

    # 0xFX65: LD Vx, [I]
    private def load_to_registers_from_memory : Instruction
      Instruction.new do |opcode|
        vx = opcode.vx

        (0..vx).each do |i|
          @registers[i] = @memory[@index + i]
        end
      end
    end
  end
end
