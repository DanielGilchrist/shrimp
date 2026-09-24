require "./shrimp"

{% if flag?(:sdl) %}
  require "sdl"
  require "./shrimp/display/sdl"
  require "./shrimp/input/sdl"

  Shrimp.main(Shrimp::Display::SDL, Shrimp::Input::SDL)
{% elsif flag?(:tui) %}
  require "./shrimp/display/tui"
  require "./shrimp/input/tui"

  Shrimp.main(Shrimp::Display::TUI, Shrimp::Input::TUI)
{% else %}
  {% raise "Specify a display backend: -Dsdl or -Dtui" %}
{% end %}
