vsim -GDebugInstance0/FilePath=./ -GDebugInstance1/FilePath=./ -L Int -L Simple -L Utilities -lib xil_defaultlib xil_defaultlib.testbench
add wave sim:/testbench/clk \
         sim:/testbench/dM \
         sim:/testbench/q 
run 200ns
