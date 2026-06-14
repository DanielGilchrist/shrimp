module Shrimp
  module Commands
    @[Kebab::Command(name: "shrimp", summary: "A CHIP-8 interpreter")]
    struct Main
      include Kebab::Parseable

      @[Kebab::Option(short: 'r', description: "Path to a ROM file")]
      getter rom : String

      def run : Nil
        display = Display::SDL.new

        STDOUT.puts("Starting interpreter...")

        interpreter = Interpreter.new(display)
        rom_bytes = File.read(rom, encoding: nil).to_slice
        interpreter.load_rom(rom_bytes)

        STDOUT.puts("Successfully loaded #{rom}")

        main_loop(interpreter)

        STDOUT.puts("Exiting...")
      end

      private def main_loop(interpreter : Interpreter)
        unimplemented_instruction = false

        loop do
          while event = ::SDL::Event.poll
            case event
            when ::SDL::Event::Quit
              return
            when ::SDL::Event::Keyboard
              if event.sym.escape?
                return
              end
            end
          end

          begin
            interpreter.step unless unimplemented_instruction
          rescue error : NotImplementedError
            unimplemented_instruction = true
            puts error
          end
        end
      end
    end
  end
end
