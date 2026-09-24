# shrimp
Name unrelated, just having fun building a CHIP-8 interpreter

### Native using SDL
<img width="823" alt="image" src="https://github.com/user-attachments/assets/9e94e8a8-9a68-42ea-8a4b-0b66185dfc3c" />

### Native in the terminal
<img width="553" height="381" alt="image" src="https://github.com/user-attachments/assets/f8c9ebaa-8d65-4838-9215-a176fa7a0085" />

### WASM in the browser
<img width="876" height="813" alt="image" src="https://github.com/user-attachments/assets/7da37853-5d88-437d-8a03-2166e322d4ec" />

### Running locally
1. [Install SDL2](https://wiki.libsdl.org/SDL2/Installation)
2. `shards install`
3. `crystal run src/shrimp_sdl.cr --release -- --rom="/path/to/rom"`

#### Terminal
The display can also be rendered in the terminal.
1. `shards install`
2. `crystal run src/shrimp_tui.cr --release -- --rom="/path/to/rom"`

#### WASM
The interpreter can also be compiled to web assembly and run in the browser. This can be viewed at https://danielgilchrist.github.io/shrimp.

To compile to WASM and run the interpreter locally in your browser simply run the below script:
```sh
scripts/run_wasm_local.sh
```
**Note:** You will need `python3` (local web server to get around CORS issues with .wasm files on localhost) and `docker` installed.
