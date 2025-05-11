# shrimp
Name unrelated, just having fun building a CHIP-8 interpreter

### Native using SDL
<img width="823" alt="image" src="https://github.com/user-attachments/assets/9e94e8a8-9a68-42ea-8a4b-0b66185dfc3c" />

### WASM in the browser
<img width="906" alt="image" src="https://github.com/user-attachments/assets/a8b1dc34-82ea-4962-b315-78048762e475" />

### Running locally
1. [Install SDL2](https://wiki.libsdl.org/SDL2/Installation)
2. `crystal run src/shrimp.cr --release -- --rom="/path/to/rom"`

#### WASM
The interpreter can also be compiled to web assembly and run in the browser. This can be viewed at https://danielgilchrist.github.io/shrimp.

To compile to WASM and run the interpreter locally in your browser simply run the below script:
```sh
scripts/run_wasm_local.sh
```
**Note:** You will need `python3` and `docker` installed.
