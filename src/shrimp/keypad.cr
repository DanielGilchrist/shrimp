module Shrimp
  class Keypad
    def initialize : Nil
      @pressed = StaticArray(Bool, 16).new(false)
    end

    def press(key : Key) : Nil
      @pressed[key.value] = true
    end

    def release(key : Key) : Nil
      @pressed[key.value] = false
    end

    def pressed?(key : Key) : Bool
      @pressed[key.value]
    end

    def not_pressed?(key : Key) : Bool
      !pressed?(key)
    end
  end
end
