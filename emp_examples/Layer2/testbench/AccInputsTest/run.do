vsim -GDebugInstance0/FilePath=./ -GDebugInstance1/FilePath=./ -L Int -L Simple -L Utilities -lib xil_defaultlib xil_defaultlib.testbench
add wave sim:/testbench/clk \
         sim:/testbench/d \
         sim:/testbench/q \
         sim:/testbench/uut/N \
         sim:/testbench/uut/M \
         sim:/testbench/uut/X0 \
         sim:/testbench/uut/XA0 \
         sim:/testbench/uut/XLA0 \
         sim:/testbench/uut/Y0 \
         sim:/testbench/uut/X1 \
         sim:/testbench/uut/XA1 \
         sim:/testbench/uut/XLA1 \
         sim:/testbench/uut/Y1 \
         sim:/testbench/uut/YA1 \
         sim:/testbench/uut/X2 \
         sim:/testbench/uut/XA2 \
         sim:/testbench/uut/Y64
run 200ns
