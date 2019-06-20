project(fost-swift)
cmake_minimum_required(VERSION 3.12)

add_library(fost-swift
        src/dirent.c
        src/settings.mm
        src/webserver.mm
    )
target_link_libraries(fost-swift fost-urlhandler)
target_include_directories(fost-swift PUBLIC include)

