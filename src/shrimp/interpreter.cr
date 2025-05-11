require "./opcode"

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

      @table0 = [
        clear_screen,
        return_from_subroutine,
      ]

      @table8 = [] of Instruction
      @tableE = [] of Instruction
      @tableF = [] of Instruction

      @table = [
        Instruction.new { |opcode| @table0[opcode.lowest_nibble].call(opcode) },
        jump,
        call,
        skip_if_register_equals_value,
        skip_if_register_not_equals_value,
        skip_if_registers_equal,
        load_register_with_value,
        add_register_with_value,
        unimplemented,
        unimplemented,
        set_index,
        unimplemented,
        unimplemented,
        draw_sprite,
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

      @display.render
    end

    # TODO: Remove this once all instructions are implemented
    private def unimplemented : Instruction
      Instruction.new do |opcode|
        idx = opcode.instruction_type
        raise(NotImplementedError.new("opcode #{opcode} | index: #{idx}"))
      end
    end

    private def load_fonts
      FONTSET.each_with_index do |byte, i|
        @memory[FONTSET_START_ADDRESS + i] = byte
      end
    end

    private def execute(opcode : Opcode)
      idx = opcode.instruction_type

      {% if flag?(:debug) %}
        instruction = @table[idx]?

        if instruction
          puts opcode
          instruction.call(opcode)
        else
          unimplemented.call(opcode)
        end
      {% else %}
        @table[idx].call(opcode)
      {% end %}
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
  end
end
