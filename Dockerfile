FROM --platform=linux/arm64 crystallang/crystal:latest

RUN apt-get update && \
    apt-get install -y git curl python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L -o /tmp/wasi-sdk.tar.gz https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-20/wasi-sdk-20.0-linux.tar.gz && \
    tar xf /tmp/wasi-sdk.tar.gz -C /opt && \
    rm /tmp/wasi-sdk.tar.gz

ENV PATH="/opt/wasi-sdk-20.0/bin:${PATH}"

WORKDIR /app

COPY . /app

RUN shards install

CMD ["sh", "-c", "lib/js/scripts/build.sh src/shrimp_web.cr --esm -o web/main.wasm && sed -i '1s|const wasmSource = \"web/main.wasm\";|const wasmSource = \"main.wasm\";|' web/main.mjs && echo 'Build complete! Files are in the web/ directory.'"]
