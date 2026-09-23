require "./shrimp"

{% if flag?(:sdl) %}
  require "sdl"
  require "./shrimp/display/sdl"

  Shrimp.main(Shrimp::Display::SDL)
{% elsif flag?(:tui) %}
  require "./shrimp/display/tui"

  Shrimp.main(Shrimp::Display::TUI)
{% else %}
  {% raise "Specify a display backend: -Dsdl or -Dtui" %}
{% end %}
