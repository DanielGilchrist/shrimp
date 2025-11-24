const wasmSource = "main.wasm";
const isDenoRuntime = !!globalThis.Deno;
const isNodeRuntime = !!globalThis.process;

const __utf8Encoder = new TextEncoder();
const __utf8Decoder = new TextDecoder("utf-8", { fatal: true });
const __heap = [];
const __free = [];
let __memory;
let __string_type_id;
let __exports;

function __make_ref(element) {
  const index = __free.length ? __free.pop() : __heap.length;
  __heap[index] = element;
  return index;
}

function __drop_ref(index) {
  __heap[index] = undefined;
  __free.push(index);
}

  function __helper_1(str) { // write String
    const data = __utf8Encoder.encode(str);
    const ptr = __exports.__crystal_malloc_atomic(13 + data.byteLength);
    __memory.setUint32(ptr, __string_type_id, true);
    __memory.setUint32(ptr + 4, data.byteLength, true);
    __memory.setUint32(ptr + 8, str.length, true);
    for (let i = 0; i < data.byteLength; i++) {
      __memory.setUint8(ptr + 12 + i, data[i]);
    }
    __memory.setUint8(ptr + 12 + data.byteLength, 0);
    return ptr;
  }

  function __helper_3(pos, len) { // read String
    return __utf8Decoder.decode(new Uint8Array(__memory.buffer, pos, len));
  }

async function init() {
  if (__exports) return;

  const nodeCrypto = isNodeRuntime && require("crypto");
  const nodeFsPromises = isNodeRuntime && require("fs/promises");

  const imports = {
    env: {
      _js3(arg1) { // JSExportHelpers.__export_0_get_arg_0 
 return __helper_1((() => { 
  return __heap[arg1][0];
 })()); },
      _js4(arg1, arg2) { // JSExportHelpers.__export_0_set_result 
 
  __heap[arg1] = (arg2 === 1);
 },
      _js5(arg1) { // JSExportHelpers.__export_1_set_result 
 
  __heap[arg1] = null;
 },
      _js59() { // Web.get_window 
 return __make_ref((() => { 
  return window;
 })()); },
      _js62(arg1, arg2) { // Web::Node#append_child 
 
  return __heap[arg1].appendChild(__heap[arg2]);
 },
      _js70(arg1, arg2, arg3) { // Web::CanvasContext#internal_setter_fill_style 
 
  __heap[arg1].fillStyle = __helper_3(arg2, arg3);
 },
      _js71(arg1, arg2, arg3, arg4, arg5) { // Web::CanvasContext#fill_rect 
 
  return __heap[arg1].fillRect(arg2, arg3, arg4, arg5);
 },
      _js73(arg1, arg2, arg3) { // Web::HTMLCanvasElement#get_context 
 return __make_ref((() => { 
  return __heap[arg1].getContext(__helper_3(arg2, arg3));
 })()); },
      _js76(arg1, arg2) { // Web::HTMLCanvasElement#internal_setter_width 
 
  __heap[arg1].width = arg2;
 },
      _js77(arg1, arg2) { // Web::HTMLCanvasElement#internal_setter_height 
 
  __heap[arg1].height = arg2;
 },
      _js78(arg1, arg2, arg3, arg5, arg6) { // Web::HTMLCanvasElement#set_attribute 
 
  return __heap[arg1].setAttribute(__helper_3(arg2, arg3), __helper_3(arg5, arg6));
 },
      _js80(arg1, arg2, arg3) { // Web::HTMLDocument#create_element 
 return __make_ref((() => { 
  return __heap[arg1].createElement(__helper_3(arg2, arg3));
 })()); },
      _js81(arg1) { // Web::HTMLDocument#body 
 return __make_ref((() => { 
  return __heap[arg1].body;
 })()); },
      _js84(arg1) { // Web::Window#document 
 return __make_ref((() => { 
  return __heap[arg1].document;
 })()); },
    },
    wasi_snapshot_preview1: {
      fd_close() {
        throw new Error("fd_close");
      },
      fd_fdstat_get(fd, buf) {
        if (fd > 2) return 8; // WASI_EBADF
        __memory.setUint8(buf, 4, true); // WASI_FILETYPE_REGULAR_FILE
        __memory.setUint16(buf + 2, 0, true);
        __memory.setUint16(buf + 4, 0, true);
        __memory.setBigUint64(buf + 8, BigInt(0), true);
        __memory.setBigUint64(buf + 16, BigInt(0), true);
        return 0;
      },
      fd_fdstat_set_flags(fd) {
        if (fd > 2) return 8; // WASI_EBADF
        throw new Error("fd_fdstat_set_flags");
      },
      fd_filestat_get(fd, buf) {
        if (fd > 2) return 8; // WASI_EBADF
        __memory.setBigUint64(buf, BigInt(0), true);
        __memory.setBigUint64(buf + 8, BigInt(0), true);
        __memory.setUint8(buf + 16, 4, true); // WASI_FILETYPE_REGULAR_FILE
        __memory.setBigUint64(buf + 24, BigInt(1), true);
        __memory.setBigUint64(buf + 32, BigInt(0), true);
        __memory.setBigUint64(buf + 40, BigInt(0), true);
        __memory.setBigUint64(buf + 48, BigInt(0), true);
        __memory.setBigUint64(buf + 56, BigInt(0), true);
        return 0;
      },
      fd_prestat_get() {
        return 8; // WASI_EBADF
      },
      fd_prestat_dir_name() {
        return 8; // WASI_EBADF
      },
      fd_seek() {
        throw new Error("fd_seek");
      },
      fd_read() {
        throw new Error("fd_read");
      },
      path_create_directory() {
        throw new Error("path_create_directory");
      },
      path_filestat_get() {
        throw new Error("path_filestat_get");
      },
      path_open() {
        throw new Error("path_open");
      },
      fd_write(fd, iovs, length, bytes_written_ptr) {
        if (fd < 1 || fd > 2) return 8; // WASI_EBADF
        if (__memory.buffer.byteLength == 0) {
          __memory = new DataView(__exports.memory.buffer);
        }
        let bytes_written = 0;
        for (let i = 0; i < length; i++) {
          const buf = __memory.getUint32(iovs + i * 8, true);
          const len = __memory.getUint32(iovs + i * 8 + 4, true);
          bytes_written += len;
          if (isDenoRuntime) {
            Deno.writeAllSync(fd === 1 ? Deno.stdout : Deno.stderr, new Uint8Array(__memory.buffer, buf, len));
          } else if (isNodeRuntime) {
            const stream = fd === 1 ? process.stdout : process.stderr;
            stream.write(new Uint8Array(__memory.buffer, buf, len));
          } else {
            (fd === 1 ? console.log : console.error)(__utf8Decoder.decode(new Uint8Array(__memory.buffer, buf, len)));
          }
        }
        __memory.setUint32(bytes_written_ptr, bytes_written, true);
        return 0;
      },
      proc_exit(exitcode) {
        throw new Error("proc_exit " + exitcode);
      },
      random_get(buf, len) {
        if (__memory.buffer.byteLength < len) {
          __memory = new DataView(__exports.memory.buffer);
        }
        if (isNodeRuntime) {
          nodeCrypto.randomBytes(len).copy(new Uint8Array(__memory.buffer, buf, len));
        } else {
          crypto.getRandomValues(new Uint8Array(__memory.buffer, buf, len));
        }
        return 0;
      },
      environ_get() {
        return 0;
      },
      environ_sizes_get(count_ptr, buf_size_ptr) {
        if (__memory.buffer.byteLength == 0) {
          __memory = new DataView(__exports.memory.buffer);
        }
        __memory.setUint32(count_ptr, 0, true);
        __memory.setUint32(buf_size_ptr, 0, true);
        return 0;
      },
      clock_time_get(clock_id, precision, time_ptr) {
        const time = BigInt((clock_id === 0 ? Date.now() : performance.now()) * 1000000);
        __memory.setBigUint64(time_ptr, time, true);
        return 0;
      },
    }
  };

  const { instance } =
    isDenoRuntime ?
      await WebAssembly.instantiate(await Deno.readFile(wasmSource), imports) :
    isNodeRuntime ?
      await WebAssembly.instantiate(await nodeFsPromises.readFile(wasmSource), imports) :
      await WebAssembly.instantiateStreaming(fetch(wasmSource), imports);

  __exports = instance.exports;
  __exports.memory.grow(1);
  __memory = new DataView(__exports.memory.buffer);
  __string_type_id = __exports.__js_bridge_get_type_id(0);
  __exports._start();
}

if (typeof exports === "object") {
  module.exports = init;
} else {
  init().catch(console.error);
}

init.init_interpreter = (...args) => {
  const slot = __make_ref(args);
  __exports.__export_0(slot);
  const result = __heap[slot];
  __drop_ref(slot);
  return result;
};

init.cycle_interpreter = (...args) => {
  const slot = __make_ref(args);
  __exports.__export_1(slot);
  const result = __heap[slot];
  __drop_ref(slot);
  return result;
};

if (isNodeRuntime && require.main === module) {
  init().catch(err => {
    console.error(err);
    process.exit(1);
  });
}
