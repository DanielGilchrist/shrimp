require "sdl"

require "./shrimp"
require "./shrimp/display/sdl"
require "./shrimp/input/sdl"

Shrimp.main(Shrimp::Display::SDL, Shrimp::Input::SDL)
