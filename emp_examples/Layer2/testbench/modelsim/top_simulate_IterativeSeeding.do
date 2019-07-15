do {top_compile_IterativeSeeding.do}
vsim -novopt -GDebugInstance/FilePath="DebuggingOutput/" -voptargs="+acc" -L Utilities -L PFChargedObj -L Layer2 -L Interfaces -L Utilities -L TDeltaR2 -lib xil_defaultlib Layer2.top
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run 504.0 ns
