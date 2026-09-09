cmake_minimum_required(VERSION 3.16)
project(re2_wasm CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(ABSL_PROPAGATE_CXX_STD ON CACHE BOOL "" FORCE)
set(ABSL_ENABLE_INSTALL ON CACHE BOOL "" FORCE)
set(BUILD_TESTING OFF CACHE BOOL "" FORCE)

if(NOT DEFINED ABSEIL_SOURCE_DIR)
  if(DEFINED ENV{ABSEIL_SOURCE_DIR})
    set(ABSEIL_SOURCE_DIR "$ENV{ABSEIL_SOURCE_DIR}")
  elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/deps/abseil-cpp")
    set(ABSEIL_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/deps/abseil-cpp")
  else()
    include(FetchContent)
    FetchContent_Declare(
      abseil_cpp
      GIT_REPOSITORY https://github.com/abseil/abseil-cpp.git
      GIT_TAG        20240116.2
    )
    FetchContent_MakeAvailable(abseil_cpp)
    set(ABSEIL_SOURCE_DIR "${abseil_cpp_SOURCE_DIR}")
  endif()
endif()

if(NOT TARGET absl::base)
  add_subdirectory("${ABSEIL_SOURCE_DIR}" abseil-cpp EXCLUDE_FROM_ALL)
endif()

set(RE2_BUILD_TESTING OFF CACHE BOOL "" FORCE)
add_subdirectory(deps/re2 re2 EXCLUDE_FROM_ALL)

add_executable(re2_wasm wrap/re2_wrap.cc)
target_link_libraries(re2_wasm PRIVATE re2::re2)
target_include_directories(re2_wasm PRIVATE deps/re2 "${ABSEIL_SOURCE_DIR}")

set_target_properties(re2_wasm PROPERTIES
  OUTPUT_NAME "re2"
  SUFFIX ".js"
  LINK_FLAGS "--bind -s WASM=1 -s WASM_ASYNC_COMPILATION=0 -s NODEJS_CATCH_EXIT=0 -s NODEJS_CATCH_REJECTION=0"
)
