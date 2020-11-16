export BUILD_SCRIPT = $(PWD)/../submodules/ruckus/system_vivado.mk

# Define target output
target: bit

# Define Firmware Version Number
export PRJ_VERSION = 0x51091000

export PROJECT = top

#Define target part
export PRJ_PART = xcvu9p-flgc2104-2L-e

export PARALLEL_SYNTH = 24

export TOP_DIR = $(abspath $(PWD)/..)
 
# Use top level makefile
include $(BUILD_SCRIPT)

