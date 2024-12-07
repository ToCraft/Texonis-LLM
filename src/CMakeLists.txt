# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(texonis_llm_library VERSION 0.0.1 LANGUAGES C)

add_library(texonis_llm SHARED
  "texonis_llm.c"
)

set_target_properties(texonis_llm PROPERTIES
  PUBLIC_HEADER texonis_llm.h
  OUTPUT_NAME "texonis_llm"
)

target_compile_definitions(texonis_llm PUBLIC DART_SHARED_LIB)
