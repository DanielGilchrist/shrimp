ARG CRYSTAL_VERSION=latest
FROM crystallang/crystal:${CRYSTAL_VERSION}

RUN apt-get update && \
    apt-get install -y git curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L -o /tmp/wasi-sdk.tar.gz https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-20/wasi-sdk-20.0-linux.tar.gz && \
    tar xf /tmp/wasi-sdk.tar.gz -C /opt && \
    rm /tmp/wasi-sdk.tar.gz

ENV PATH="/opt/wasi-sdk-20.0/bin:${PATH}"

WORKDIR /app
COPY . /app
RUN shards install

ENTRYPOINT ["bash", "-c", "lib/js/scripts/build.sh src/shrimp_web.cr -o docs/main.wasm && find docs -name \"*.js\" | xargs sed -i 's|const wasmSource = \"docs/main.wasm\"|const wasmSource = \"main.wasm\"|g'"]
