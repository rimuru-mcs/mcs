# Install script for directory: /opt/msr/repo/msr

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
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

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/opt/msr/repo/msr/build/linux-release/common/cmake_install.cmake")
  include("/opt/msr/repo/msr/build/linux-release/libs/cmake_install.cmake")
  include("/opt/msr/repo/msr/build/linux-release/submodules/fmt/cmake_install.cmake")
  include("/opt/msr/repo/msr/build/linux-release/submodules/libuv/cmake_install.cmake")
  include("/opt/msr/repo/msr/build/linux-release/libs/zlibng/cmake_install.cmake")
  include("/opt/msr/repo/msr/build/linux-release/submodules/recastnavigation/cmake_install.cmake")
  include("/opt/msr/repo/msr/build/linux-release/shared_memory/cmake_install.cmake")
  include("/opt/msr/repo/msr/build/linux-release/world/cmake_install.cmake")
  include("/opt/msr/repo/msr/build/linux-release/zone/cmake_install.cmake")
  include("/opt/msr/repo/msr/build/linux-release/ucs/cmake_install.cmake")
  include("/opt/msr/repo/msr/build/linux-release/queryserv/cmake_install.cmake")
  include("/opt/msr/repo/msr/build/linux-release/eqlaunch/cmake_install.cmake")
  include("/opt/msr/repo/msr/build/linux-release/loginserver/cmake_install.cmake")

endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "/opt/msr/repo/msr/build/linux-release/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
