BUILD_DIR ?= build/cmake
CMAKE_EXTRA_ARGS ?=
CMAKE ?= $(shell which cmake || echo cmake)

all: wasm/re2.js

wasm/re2.js: wrap/re2_wrap.cc CMakeLists.txt
	mkdir -p wasm
	emcmake $(CMAKE) -B $(BUILD_DIR) -G Ninja $(CMAKE_EXTRA_ARGS)
	$(CMAKE) --build $(BUILD_DIR) --target re2_wasm
	cp $(BUILD_DIR)/re2.js wasm/re2.js
	cp $(BUILD_DIR)/re2.wasm wasm/re2.wasm

clean:
	rm -rf $(BUILD_DIR) wasm/re2.js wasm/re2.wasm

.PHONY: all clean

