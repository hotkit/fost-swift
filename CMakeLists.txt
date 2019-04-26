project(fost-swift)
cmake_minimum_required(VERSION 3.12)

add_library(fost-swift src/settings.mm)
target_link_libraries(fost-swift fost-core)
target_include_directories(fost-swift PUBLIC include)

