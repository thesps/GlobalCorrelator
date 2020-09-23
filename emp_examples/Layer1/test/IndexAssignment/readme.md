# Test Description
A standalone test of the assignment of addresses to input links based on their order in the region.
An input/output file reader and writer are provided expecting `PkgHGCAbstractRouter.DataType.tData` data.
Each line in the file will be read on consecutive clock cycles.
Each column in the line will be read to different elements of the input vector in the same cycle.
Each field of the record should appear in the same order they are defined in the package, with another delimiter between elements of the vector on one line.

## Environment
Expected setup is a standard ipbb workspace with `proj/` and `src/` directories.
Under `src/`, expect:
```
GlobalCorrelator/ # this repo
RuflCore/ # from https://gitlab.cern.ch/rufl/RuflCore/ @ commit 95cff0d1
```

## Steps
Compile the Modelsim simulation library with `mkdir libs && bash msim_compile.sh`
Create a test input file with randomised values `python generate_input.py`
Run the simulation with `vsim -do msim_run.tcl`
