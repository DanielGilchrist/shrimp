module Shrimp
  abstract class Input
    abstract def poll(keypad : Keypad) : Bool
  end
end
