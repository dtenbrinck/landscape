# Install script for directory: D:/MotionBoxes/flexBox/flexBox_CPP/source/examples

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "C:/Program Files/FlexBox")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/MotionBoxes/flexBox-master/flexBox_CPP-f90f5a3d07cad29ec5c578396b0461ca8fa92df6/build/bin/exampleROF.exe")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "D:/MotionBoxes/flexBox-master/flexBox_CPP-f90f5a3d07cad29ec5c578396b0461ca8fa92df6/build/bin" TYPE EXECUTABLE FILES "D:/MotionBoxes/flexBox-master/flexBox_CPP-f90f5a3d07cad29ec5c578396b0461ca8fa92df6/build/examples/Debug/exampleROF.exe")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/MotionBoxes/flexBox-master/flexBox_CPP-f90f5a3d07cad29ec5c578396b0461ca8fa92df6/build/bin/exampleROF.exe")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "D:/MotionBoxes/flexBox-master/flexBox_CPP-f90f5a3d07cad29ec5c578396b0461ca8fa92df6/build/bin" TYPE EXECUTABLE FILES "D:/MotionBoxes/flexBox-master/flexBox_CPP-f90f5a3d07cad29ec5c578396b0461ca8fa92df6/build/examples/Release/exampleROF.exe")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/MotionBoxes/flexBox-master/flexBox_CPP-f90f5a3d07cad29ec5c578396b0461ca8fa92df6/build/bin/exampleROF.exe")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "D:/MotionBoxes/flexBox-master/flexBox_CPP-f90f5a3d07cad29ec5c578396b0461ca8fa92df6/build/bin" TYPE EXECUTABLE FILES "D:/MotionBoxes/flexBox-master/flexBox_CPP-f90f5a3d07cad29ec5c578396b0461ca8fa92df6/build/examples/MinSizeRel/exampleROF.exe")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "D:/MotionBoxes/flexBox-master/flexBox_CPP-f90f5a3d07cad29ec5c578396b0461ca8fa92df6/build/bin/exampleROF.exe")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "D:/MotionBoxes/flexBox-master/flexBox_CPP-f90f5a3d07cad29ec5c578396b0461ca8fa92df6/build/bin" TYPE EXECUTABLE FILES "D:/MotionBoxes/flexBox-master/flexBox_CPP-f90f5a3d07cad29ec5c578396b0461ca8fa92df6/build/examples/RelWithDebInfo/exampleROF.exe")
  endif()
endif()

