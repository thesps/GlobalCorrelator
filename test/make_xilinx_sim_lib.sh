#!/bin/bash
outdir=$PWD/xilinx_sim_lib
vsimpath=$(dirname $(which vsim) )
echo -e "compile_simlib -language vhdl -dir $outdir -simulator modelsim -simulator_exec_path $vsimpath -library unisim -family virtexuplus\\nexit" | vivado -mode tcl
