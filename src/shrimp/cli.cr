module Shrimp
  @[Kebab::Command(name: "shrimp", summary: "A CHIP-8 interpreter")]
  struct CLI
    include Kebab::Parseable

    @[Kebab::Option(short: 'r', description: "Path to a ROM file")]
    getter rom : String

    @[Kebab::Option(short: 't', description: "Log every executed opcode")]
    getter? trace : Bool = false
  end
end
