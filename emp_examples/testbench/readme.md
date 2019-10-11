First of all make sure the PF core simulation tcl file is created:
```
cd ../PF_IP_XYZ/firmware/cfg
bash gen_dep_file.sh
```

To run the Modelsim testbench, provide a pattern file mp7_input_patterns.txt.
Setup the directory:
`mkdir modelsim_lib`
Then run the simulation:
`vsim -batch -do top_simulate.do`

The output links module automatically writes all valid input to a text file, name LinksOut.txt

The input pattern file and output debug file paths can be changed by editing the `vsim` command in `top_simulate.do`:
`vsim -G/top/g1/MP7CaptureFileReaderInstance/FileName="mp7_input_patterns.txt" -GDebugInstance/FilePath="./" -voptargs="+acc" -L Utilities -L Link -lib xil_defaultlib xil_default    lib.top`
