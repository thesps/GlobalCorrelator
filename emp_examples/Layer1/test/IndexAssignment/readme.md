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
Setup and compile the Modelsim simulation library with `mkdir libs testfiles && bash msim_compile.sh`
Create a test input file with randomised values: `python util.py`
Run the simulation with `vsim -do msim_run.tcl`. As written, this command will open the Modelsim GUI. To execute without opening the window, do instead `vsim -c -do msim_run.tcl`, then type `quit` when the simulation finishes. By default several debugging files will be written to the directory `testfiles/` and the module output will be written to a file `SimulationOutput.txt` 

Parse the output with Python:
```
import util
data = util.parse_file('SimulationOutput.txt')
```
You can then analyse and check the performance of the module.
For a quick test of test success:
```
d_sim = util.valid_frames(util.parse_file('SimulationOutput.txt'))
d_ref = util.valid_frames(util.algo_ref(util.parse_file('SimulationInput.txt')))
print((d_ref == d_sim).all())
```
This check will return true only if each field of `LinkData` at each element of the two arrays - one from Modelsim and the other from the Python reference - match.
