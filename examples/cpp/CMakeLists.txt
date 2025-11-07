cmake_minimum_required(VERSION 3.15)
project(WhisperChain_Crypto VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Compiler flags
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-Wall -Wextra -Wpedantic -O2)
endif()

# Library
add_library(whisper_crypto STATIC
    crypto/keccak256.cpp
    crypto/secp256k1_wrapper.cpp
)

target_include_directories(whisper_crypto PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# Example executable
add_executable(crypto_example
    examples/main.cpp
)

target_link_libraries(crypto_example PRIVATE whisper_crypto)

# Tests (optional)
option(BUILD_TESTS "Build tests" ON)

if(BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

# Installation
install(TARGETS whisper_crypto
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

install(DIRECTORY crypto/
    DESTINATION include/whisper/crypto
    FILES_MATCHING PATTERN "*.h"
)
