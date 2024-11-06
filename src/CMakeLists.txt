# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)


project(enet_library VERSION 0.0.1 LANGUAGES C)

add_library(enet SHARED
  "enet.c"
)

set_target_properties(enet PROPERTIES
  PUBLIC_HEADER enet.h
  OUTPUT_NAME "enet"
)

if(MSVC)
  target_compile_options(enet PRIVATE /W3)
  target_link_libraries(enet PRIVATE ws2_32.lib winmm.lib)
elseif(MINGW)
  target_link_libraries(enet PUBLIC -lws2_32 -lwinmm)
endif()

target_compile_definitions(enet PUBLIC DART_SHARED_LIB -DENET_DLL)
