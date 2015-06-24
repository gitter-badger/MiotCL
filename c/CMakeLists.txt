# Create MiotCL library and examples

# add the binary tree directory to the search path for include files and linking
include_directories( ${CMAKE_CURRENT_BINARY_DIR} )
link_directories( ${CMAKE_CURRENT_BINARY_DIR} )

# post build: mv miotcl_.h miotcl.h
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/miotcl.h")
  file(RENAME miotcl.h miotcl_.h)
endif()
file(COPY DLLDefines.h DESTINATION ${CMAKE_CURRENT_BINARY_DIR})

set(SOURCES_MiotCL
big.c
fp.c
ecp.c
hash.c
rand.c
aes.c
gcm.c
oct.c
rom.c
fp2.c
ecp2.c
fp4.c
fp12.c
ff.c)

# Build MiotCL
add_library(miotcl ${LIB_TYPE} ${SOURCES_MiotCL} version.c)

if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  if(BUILD_SHARED_LIBS)
    message(STATUS "Build shared libs")
    target_link_libraries (miotcl libm.so) 
  else()
    message(STATUS "Build static libs")
    target_link_libraries (miotcl libm.a) 
  endif(BUILD_SHARED_LIBS)
endif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")

# Build libmpin
if(BUILD_MPIN)
  add_library(mpin ${LIB_TYPE} pair.c mpin.c utils.c)
  target_link_libraries (mpin miotcl) 
  add_executable (testmpin testmpin.c)
  target_link_libraries (testmpin mpin) 
endif(BUILD_MPIN)

  
# Copy built libs to c/tests which allows testing without
# having to install the libs.
if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    message(STATUS "Copy libmiotcl.dll to c/tests for testing")
    add_custom_command(
                TARGET miotcl
                POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_BINARY_DIR}/libmiotcl.dll" "${PROJECT_BINARY_DIR}/c/tests/")
    message(STATUS "Copy libmiotcl.dll to c/tests for testing")

    if(BUILD_MPIN)
      add_custom_command(
                  TARGET mpin
                  POST_BUILD
                  COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_BINARY_DIR}/libmpin.dll" "${PROJECT_BINARY_DIR}/c/tests/")
      message(STATUS "Copy libmpin.dll to c/tests for testing")
    endif(BUILD_MPIN)

endif(${CMAKE_SYSTEM_NAME} MATCHES "Windows")

# Copy built libs to pythonCFFI which allows testing without
# having to install the libs.
if (BUILD_PYTHON AND BUILD_SHARED_LIBS)

  if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")

    if(BUILD_MPIN)
      message(STATUS "Copy libmpin.so to pythonCFFI for testing")
      add_custom_command(
                  TARGET mpin
                  POST_BUILD
                  COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_BINARY_DIR}/libmpin.so" "${PROJECT_BINARY_DIR}/pythonCFFI/")
    endif(BUILD_MPIN)

  endif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")

  if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    message(STATUS "Copy libmiotcl.dll to pythonCFFI for testing")
    add_custom_command(
                TARGET miotcl
                POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_BINARY_DIR}/libmiotcl.dll" "${PROJECT_BINARY_DIR}/pythonCFFI/")

    if(BUILD_MPIN)
      add_custom_command(
                  TARGET mpin
                  POST_BUILD
                  COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_BINARY_DIR}/libmpin.dll" "${PROJECT_BINARY_DIR}/pythonCFFI/")
      message(STATUS "Copy libmpin.dll to pythonCFFI for testing")
    endif(BUILD_MPIN)

  endif(${CMAKE_SYSTEM_NAME} MATCHES "Windows")

  if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")

    message(STATUS "Copy libmiotcl.dylib to pythonCFFI for testing")
    add_custom_command(
                TARGET miotcl
                POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_BINARY_DIR}/libmiotcl.dylib" "${PROJECT_BINARY_DIR}/pythonCFFI/")

    if(BUILD_MPIN)
      message(STATUS "Copy libmpin.dylib to pythonCFFI for testing")
      add_custom_command(
                  TARGET mpin
                  POST_BUILD
                  COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_BINARY_DIR}/libmpin.dylib" "${PROJECT_BINARY_DIR}/pythonCFFI/")
    endif(BUILD_MPIN)

  endif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")


endif (BUILD_PYTHON AND BUILD_SHARED_LIBS)

# Example programs
add_executable (testecm testecm.c ecdh.c)
add_executable (testecdh testecdh.c ecdh.c)
add_executable (testrsa testrsa.c rsa.c)
target_link_libraries (testecm miotcl) 
target_link_libraries (testecdh miotcl) 
target_link_libraries (testrsa miotcl) 

add_subdirectory (tests)

# Install libs and headers
if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  install(DIRECTORY DESTINATION include/miotcl DIRECTORY_PERMISSIONS
          OWNER_WRITE OWNER_READ OWNER_EXECUTE
          GROUP_WRITE GROUP_READ
          WORLD_WRITE WORLD_READ WORLD_EXECUTE)
  install (TARGETS miotcl DESTINATION lib PERMISSIONS
          OWNER_WRITE OWNER_READ OWNER_EXECUTE
          GROUP_READ GROUP_EXECUTE
          WORLD_READ WORLD_EXECUTE)
  install (FILES ${CMAKE_CURRENT_BINARY_DIR}/miotcl.h DESTINATION include/miotcl PERMISSIONS
          OWNER_WRITE OWNER_READ OWNER_EXECUTE
          GROUP_READ GROUP_EXECUTE
          WORLD_READ WORLD_EXECUTE)
  install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/utils.h DESTINATION include/miotcl PERMISSIONS
          OWNER_WRITE OWNER_READ OWNER_EXECUTE
          GROUP_READ GROUP_EXECUTE
          WORLD_READ WORLD_EXECUTE)
  install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/DLLDefines.h DESTINATION include/miotcl PERMISSIONS
          OWNER_WRITE OWNER_READ OWNER_EXECUTE
          GROUP_READ GROUP_EXECUTE
          WORLD_READ WORLD_EXECUTE)

  if(BUILD_MPIN)
    install (TARGETS mpin DESTINATION lib PERMISSIONS
            OWNER_WRITE OWNER_READ OWNER_EXECUTE
            GROUP_READ GROUP_EXECUTE
            WORLD_READ WORLD_EXECUTE)
    install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/mpin.h DESTINATION include/miotcl PERMISSIONS
            OWNER_WRITE OWNER_READ OWNER_EXECUTE
            GROUP_READ GROUP_EXECUTE
            WORLD_READ WORLD_EXECUTE)
  endif(BUILD_MPIN)

endif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")

if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
  # Windows specific code
  install (TARGETS miotcl DESTINATION lib)
  install (FILES ${CMAKE_CURRENT_BINARY_DIR}/miotcl.h DESTINATION lib)
  install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/utils.h DESTINATION lib)
  install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/DLLDefines.h DESTINATION lib)
  
  if(BUILD_MPIN)
    install (TARGETS mpin DESTINATION lib)
    install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/mpin.h DESTINATION lib)
  endif(BUILD_MPIN)

endif(${CMAKE_SYSTEM_NAME} MATCHES "Windows")

if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  # Mac OS X specific code
  install(DIRECTORY DESTINATION include/miotcl DIRECTORY_PERMISSIONS
          OWNER_WRITE OWNER_READ OWNER_EXECUTE
          GROUP_WRITE GROUP_READ
          WORLD_WRITE WORLD_READ WORLD_EXECUTE)
  install (TARGETS miotcl DESTINATION lib PERMISSIONS
          OWNER_WRITE OWNER_READ OWNER_EXECUTE
          GROUP_READ GROUP_EXECUTE
          WORLD_READ WORLD_EXECUTE)
  install (FILES ${CMAKE_CURRENT_BINARY_DIR}/miotcl.h DESTINATION include/miotcl PERMISSIONS
          OWNER_WRITE OWNER_READ OWNER_EXECUTE
          GROUP_READ GROUP_EXECUTE
          WORLD_READ WORLD_EXECUTE)
  install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/utils.h DESTINATION include/miotcl PERMISSIONS
          OWNER_WRITE OWNER_READ OWNER_EXECUTE
          GROUP_READ GROUP_EXECUTE
          WORLD_READ WORLD_EXECUTE)
  install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/DLLDefines.h DESTINATION include/miotcl PERMISSIONS
          OWNER_WRITE OWNER_READ OWNER_EXECUTE
          GROUP_READ GROUP_EXECUTE
          WORLD_READ WORLD_EXECUTE)

  if(BUILD_MPIN)
    install (TARGETS mpin DESTINATION lib PERMISSIONS
            OWNER_WRITE OWNER_READ OWNER_EXECUTE
            GROUP_READ GROUP_EXECUTE
            WORLD_READ WORLD_EXECUTE)
    install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/mpin.h DESTINATION include/miotcl PERMISSIONS
            OWNER_WRITE OWNER_READ OWNER_EXECUTE
            GROUP_READ GROUP_EXECUTE
            WORLD_READ WORLD_EXECUTE)
  endif(BUILD_MPIN)

endif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
