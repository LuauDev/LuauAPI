cmake_minimum_required(VERSION 3.15)
project(LuauAPI VERSION 1.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Enable DLL build
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
set(BUILD_SHARED_LIBS ON)

# Add external dependencies
find_package(OpenSSL REQUIRED)
find_package(ZLIB REQUIRED)

# Source files
set(SOURCES
    LuauAPI/src/LuauAPI.cpp
    LuauAPI/src/worker.cpp
    LuauAPI/src/server.cpp
)

# Create DLL target
add_library(${PROJECT_NAME} SHARED ${SOURCES})

# Include directories
target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/LuauAPI/include
    ${CMAKE_CURRENT_SOURCE_DIR}/LuauAPI/src
    ${OPENSSL_INCLUDE_DIR}
)

# Link libraries
target_link_libraries(${PROJECT_NAME} PRIVATE
    ${OPENSSL_LIBRARIES}
    ZLIB::ZLIB
    xxhash
    zstd
    psapi
    ws2_32
)

# Windows-specific settings
if(WIN32)
    target_compile_definitions(${PROJECT_NAME} PRIVATE
        WIN32_LEAN_AND_MEAN
        NOMINMAX
        _CRT_SECURE_NO_WARNINGS
    )
endif()

# Set output directories
set_target_properties(${PROJECT_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
) 