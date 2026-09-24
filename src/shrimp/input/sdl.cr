module Shrimp
  class Input
    class SDL < Input
      KEYS = {
        LibSDL::Keycode::KEY_1 => Key::One,
        LibSDL::Keycode::KEY_2 => Key::Two,
        LibSDL::Keycode::KEY_3 => Key::Three,
        LibSDL::Keycode::KEY_4 => Key::C,
        LibSDL::Keycode::Q     => Key::Four,
        LibSDL::Keycode::W     => Key::Five,
        LibSDL::Keycode::E     => Key::Six,
        LibSDL::Keycode::R     => Key::D,
        LibSDL::Keycode::A     => Key::Seven,
        LibSDL::Keycode::S     => Key::Eight,
        LibSDL::Keycode::D     => Key::Nine,
        LibSDL::Keycode::F     => Key::E,
        LibSDL::Keycode::Z     => Key::A,
        LibSDL::Keycode::X     => Key::Zero,
        LibSDL::Keycode::C     => Key::B,
        LibSDL::Keycode::V     => Key::F,
      }

      def poll(keypad : Keypad) : Bool
        while event = ::SDL::Event.poll
          case event
          when ::SDL::Event::Quit
            return false
          when ::SDL::Event::Keyboard
            next unless event.repeat.zero?

            key = KEYS[event.sym]?
            next unless key

            if event.keydown?
              keypad.press(key)
            else
              keypad.release(key)
            end
          end
        end

        true
      end
    end
  end
end
