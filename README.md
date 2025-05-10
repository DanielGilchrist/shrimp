# shrimp
Name unrelated, just having fun building a CHIP-8 interpreter

### Native using SDL
<img width="689" alt="image" src="https://github.com/user-attachments/assets/452659db-cdca-4fe2-9aec-8d42dc5834a5" />

### WASM in the browser
<img width="1007" alt="image" src="https://github.com/user-attachments/assets/cb7dff34-cb01-464b-8939-eaa332ec5c8c" />

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
