vsim -L Int -L Bool -L HGCRouter -L Utilities -L xil_defaultlib \
-G Debug/FilePath="./testfiles/" \
-G Debug0/FilePath="./testfiles/" -G Debug1/FilePath="./testfiles/" \
-G Debug2/FilePath="./testfiles/" -G Debug3/FilePath="./testfiles/" \
xil_defaultlib.testbench;
run 2000 ns;
