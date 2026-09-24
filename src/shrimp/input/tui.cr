require "../input"
require "../terminal"

module Shrimp
  class Input
    class TUI < Input
      KEY_CTRL_C = 0x03_u8
      KEY_QUIT   = 'q'.ord.to_u8

      def initialize(@terminal : Terminal = Terminal.stdio) : Nil
        @bytes = Channel(UInt8).new(64)

        @terminal.open
        spawn { read_bytes }
      end

      def poll(keypad : Keypad) : Bool
        loop do
          select
          when byte = @bytes.receive
            return false if quit_key?(byte)
          else
            return true
          end
        end
      end

      private def quit_key?(byte : UInt8) : Bool
        byte.in?(KEY_CTRL_C, KEY_QUIT)
      end

      private def read_bytes : Nil
        while byte = @terminal.input.read_byte
          @bytes.send(byte)
        end
      end
    end
  end
end
