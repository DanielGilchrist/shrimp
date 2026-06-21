module Shrimp
  @[Kebab::Command(name: "shrimp", summary: "A CHIP-8 interpreter")]
  struct CLI
    include Kebab::Parseable

    @[Kebab::Option(short: 'r', description: "Path to a ROM file")]
    getter rom : String
  end
end
