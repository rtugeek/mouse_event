cmake_minimum_required(VERSION 3.15)
set(PROJECT_NAME "mouse_event")
project(${PROJECT_NAME} LANGUAGES CXX)

# if(NOT CMAKE_CXX_STANDARD)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# endif()

# This value is used when generating builds using this plugin, so it must not be
# changed
set(PLUGIN_NAME "mouse_event_plugin")


add_library(
  ${PLUGIN_NAME} SHARED "map_serializer.cpp" "mouse_event_plugin.cpp"
                        "map_serializer.h" )
add_custom_target(
  COMMAND cmd /C echo ${PROJECT_SOURCE_DIR}
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})

target_compile_options(${PLUGIN_NAME} PRIVATE /utf-8 /std:c++latest /bigobj)
add_definitions(-D_HAS_EXCEPTIONS=1) # error LNK2019: std::bad_cast

apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME}
                           INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/include")


target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin
set(mouse_event_bundled_libraries
    ""
    PARENT_SCOPE)
