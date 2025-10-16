cmake_minimum_required(VERSION 3.20)
project(VerilogSim NONE)

# -----------------------------
# Directories
set(SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
set(TB_DIR  "${CMAKE_CURRENT_SOURCE_DIR}/tb")
set(BUILD_DIR "${CMAKE_CURRENT_SOURCE_DIR}/build")
set(WAVE_DIR  "${CMAKE_CURRENT_SOURCE_DIR}/wave")

# Ensure output directories exist
file(MAKE_DIRECTORY ${BUILD_DIR})
file(MAKE_DIRECTORY ${WAVE_DIR})

# -----------------------------
# Find all Verilog files
file(GLOB SRC_FILES "${SRC_DIR}/*.v")
file(GLOB TB_FILES  "${TB_DIR}/*.v")

# Extract base names (without extension)
foreach(tb ${TB_FILES})
    get_filename_component(tb_name ${tb} NAME_WE)
    list(APPEND TB_BASENAMES ${tb_name})
endforeach()

# -----------------------------
# Create custom targets for each testbench
foreach(tb_name IN LISTS TB_BASENAMES)
    set(out_file "${BUILD_DIR}/${tb_name}.out")
    set(tb_file "${TB_DIR}/${tb_name}.v")

    # Compile testbench
    add_custom_command(
        OUTPUT ${out_file}
        COMMAND iverilog -o ${out_file} ${tb_file} ${SRC_FILES}
        DEPENDS ${tb_file} ${SRC_FILES}
        COMMENT "Compiling ${tb_name}"
        VERBATIM
    )

    add_custom_target(${tb_name}_build ALL DEPENDS ${out_file})

    # Run testbench
    add_custom_target(run_${tb_name}
        COMMAND ${CMAKE_COMMAND} -E echo "Running ${out_file}"
        COMMAND vvp ${out_file}
        DEPENDS ${tb_name}_build
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endforeach()

# -----------------------------
# Top-level run target (runs all testbenches)
add_custom_target(run_all)

foreach(tb_name IN LISTS TB_BASENAMES)
    if(TARGET run_${tb_name})
        add_dependencies(run_all run_${tb_name})
    endif()
endforeach()

# -----------------------------
# Clean target
add_custom_target(clean_all
    COMMAND ${CMAKE_COMMAND} -E rm -f ${BUILD_DIR}/*.out
    COMMAND ${CMAKE_COMMAND} -E rm -f ${WAVE_DIR}/*.vcd
)

# mkdir build
# cd build
# cmake ..
# cmake --build .                # compiles all testbenches
# cmake --build . --target run_all   # runs all testbenches
# cmake --build . --target clean_all # cleans build/wave
