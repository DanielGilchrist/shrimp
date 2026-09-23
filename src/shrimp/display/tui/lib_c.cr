lib LibC
  struct Winsize
    ws_row : UShort
    ws_col : UShort
    ws_xpixel : UShort
    ws_ypixel : UShort
  end

  {% if flag?(:darwin) || flag?(:bsd) %}
    TIOCGWINSZ = 0x40087468_u64
  {% else %}
    TIOCGWINSZ = 0x5413_u64
  {% end %}

  fun ioctl(fd : Int, request : ULong, ...) : Int
end
