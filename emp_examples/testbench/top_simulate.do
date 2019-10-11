do {top_compile.do}

vsim -G/top/g1/MP7CaptureFileReaderInstance/FileName="mp7_input_patterns.txt" -GDebugInstance/FilePath="./" -voptargs="+acc" -L Utilities -L Link -lib xil_defaultlib xil_defaultlib.top
set NumericStdNoWarnins 1
set StdArithNoWarnings 1

do {waves.do}

run 1000ns
#quit -f
