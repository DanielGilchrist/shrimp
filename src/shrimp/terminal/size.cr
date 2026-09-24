module Shrimp
  class Terminal
    record Size, columns : Int32, rows : Int32 do
      def fits?(other : Size) : Bool
        columns >= other.columns && rows >= other.rows
      end

      def to_s(io : IO) : Nil
        io << columns << 'x' << rows
      end
    end
  end
end
