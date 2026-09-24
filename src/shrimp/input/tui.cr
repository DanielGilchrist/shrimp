require "../input"
require "../terminal"

module Shrimp
  class Input
    class TUI < Input
      KEYS = {
        0x31_u8 => Key::One,
        0x32_u8 => Key::Two,
        0x33_u8 => Key::Three,
        0x34_u8 => Key::C,
        0x71_u8 => Key::Four,
        0x77_u8 => Key::Five,
        0x65_u8 => Key::Six,
        0x72_u8 => Key::D,
        0x61_u8 => Key::Seven,
        0x73_u8 => Key::Eight,
        0x64_u8 => Key::Nine,
        0x66_u8 => Key::E,
        0x7A_u8 => Key::A,
        0x78_u8 => Key::Zero,
        0x63_u8 => Key::B,
        0x76_u8 => Key::F,
      }

      KEY_CTRL_C = 0x03_u8

      HOLD_FRAMES = 10

      def initialize(@terminal : Terminal = Terminal.stdio) : Nil
        @bytes = Channel(UInt8).new(64)
        @held = Hash(Key, Int32).new

        @terminal.open
        spawn { read_bytes }
      end

      def poll(keypad : Keypad) : Bool
        while byte = next_byte?
          return false if quit?(byte)

          key = KEYS[byte]?
          next unless key

          @held[key] = HOLD_FRAMES
          keypad.press(key)
        end

        @held.transform_values!(&.pred)
        @held.reject! { |k, frames| frames.zero?.tap { |released| keypad.release(k) if released } }

        true
      end

      private def quit?(byte : UInt8) : Bool
        byte == KEY_CTRL_C
      end

      private def next_byte? : UInt8?
        select
        when byte = @bytes.receive
          byte
        else
          nil
        end
      end

      private def read_bytes : Nil
        while byte = @terminal.input.read_byte
          @bytes.send(byte)
        end
      end
    end
  end
end
