cmake_minimum_required(VERSION 3.1 FATAL_ERROR)
# CMP0076 - target source files relative to where target_sources is run
cmake_policy (SET CMP0076 NEW)

set(PROJECT_NAME SimpleNetExample)

project(${PROJECT_NAME} LANGUAGES Fortran)

# Build in Debug mode if not specified
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "" FORCE)
endif()

find_package(FTorch)
message(STATUS "Building with Fortran PyTorch coupling")

# Fortran example
add_executable(simplenet_fortran simplenet_fortran.f90)
target_link_libraries(simplenet_fortran PRIVATE FTorch::ftorch)
