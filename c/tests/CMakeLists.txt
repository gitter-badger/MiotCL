# Create tests

# add the binary tree directory to the search path for include files and linking
include_directories (${CMAKE_CURRENT_BINARY_DIR} ${PROJECT_SOURCE_DIR}/c ${PROJECT_BINARY_DIR}/c )
link_directories (${PROJECT_BINARY_DIR}/c)

# enable testing
enable_testing ()

#define a macro to simplify adding tests
macro (do_test arg result)
  add_test (${arg} ${arg})
  set_tests_properties (${arg}
    PROPERTIES PASS_REGULAR_EXPRESSION ${result}
    )
endmacro ()

if(BUILD_MPIN)
  add_executable (test_mpin test_mpin.c)
  add_executable (test_mpin_good test_mpin_good.c)
  add_executable (test_mpin_bad_pin test_mpin_bad_pin.c)
  add_executable (test_mpin_bad_token test_mpin_bad_token.c)
  add_executable (test_mpin_expired_tp test_mpin_expired_tp.c)
  add_executable (test_mpin_tp test_mpin_tp.c config.h)
  add_executable (test_mpin_random test_mpin_random.c config.h)
  add_executable (test_mpinfull test_mpinfull.c)
  #add_executable (test_mpinfull_random test_mpinfull_random.c config.h)
  # Link the executable to the libraries
  target_link_libraries (test_mpin mpin) 
  target_link_libraries (test_mpin_good mpin) 
  target_link_libraries (test_mpin_bad_pin mpin) 
  target_link_libraries (test_mpin_bad_token mpin) 
  target_link_libraries (test_mpin_expired_tp mpin) 
  target_link_libraries (test_mpin_tp mpin) 
  target_link_libraries (test_mpin_random mpin) 
  target_link_libraries (test_mpinfull mpin) 
  #target_link_libraries (test_mpinfull_random mpin) 
  # tests
  do_test (test_mpin "SUCCESS Error Code 0")
  do_test (test_mpin_good "SUCCESS Error Code 0")
  do_test (test_mpin_bad_pin "FAILURE")
  do_test (test_mpin_bad_token "FAILURE Invalid Token Error Code -19")
  do_test (test_mpin_expired_tp "FAILURE Invalid Token Error Code -19")
  do_test (test_mpin_tp "Iteration ${MPIN_TIME_PERMIT_TESTS} SUCCESS Error Code 0")
  do_test (test_mpin_random "Iteration ${MPIN_RANDOM_TESTS} SUCCESS Error Code 0")
  do_test (test_mpinfull "SUCCESS")
  #do_test (test_mpinfull_random "Iteration ${MPIN_RANDOM_TESTS} SUCCESS")
endif(BUILD_MPIN)
  
# General tests
add_executable (test_rsa ${PROJECT_SOURCE_DIR}/c/rsa.c test_rsa.c)
add_executable (test_ecm ${PROJECT_SOURCE_DIR}/c/ecdh.c test_ecm.c)
add_executable (test_ecdh ${PROJECT_SOURCE_DIR}/c/ecdh.c test_ecdh.c)
add_executable (test_version test_version.c)
# Link the executable to the libraries
target_link_libraries (test_rsa miotcl) 
target_link_libraries (test_ecm miotcl) 
target_link_libraries (test_ecdh miotcl) 
target_link_libraries (test_version miotcl) 
# tests  
do_test (test_rsa "SUCCESS")
do_test (test_ecm "SUCCESS")
do_test (test_ecdh "SUCCESS")
do_test (test_version "Version: ${MiotCL_VERSION_MAJOR}.${MiotCL_VERSION_MINOR}.${MiotCL_VERSION_PATCH} OS: ${OS} FIELD CHOICE: ${FIELD_CHOICE} CURVE TYPE: ${CURVE_TYPE} WORD_LENGTH: ${WORD_LENGTH}")
