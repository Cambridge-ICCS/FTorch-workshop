cmake_minimum_required(VERSION 3.18...3.31)
cmake_policy(SET CMP0076 NEW)

set(PROJECT_NAME HelloFortran)

project(${PROJECT_NAME} LANGUAGES Fortran)

# Build in Release mode if not specified
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE
      Release
      CACHE STRING "" FORCE)
endif()

add_executable(hello_fortran hello_fortran.f90 math_mod.f90)
