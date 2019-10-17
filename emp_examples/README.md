This branch is for development of a version of PF & PUPPI running on a KU15P FPGA on a Serenity card, with the Vertex received from a separate KU15P over a 25Gb/s link.
The firmware expects the track, calo, etc inputs to the PF&PUPPI IP to be written into link buffers first, after which the vertex is sent from the second board.

##### Step 1: Install ipbb
Using github.com/ipbus/ipbb master at commit 31da1f3 (just after tag v0.5.2)
For simulation only, github.com/thesps/ipbb branch xil\_defaultlib is required.
The full support needed for the use of VHDL libraries in this project is not currently in an ipbb tag.
The subset for synthesis ought to be in v0.5.3.

##### Step 2: emp-fwk and other repos:
Using:

| Repository       | (Fork)/(Tag/Branch/Version) | URL                                              |
|------------------|-----------------------------|--------------------------------------------------|
| emp-fwk          | v0.3.0                      | https://gitlab.cern.ch/p2-xware/firmware/emp-fwk |
| ipbus-firmware   | v1.5                        | https://github.com/ipbus/ipbus-firmware          |
| legacy-ttc       | v2.1                        | https://gitlab.cern.ch/ttc/legacy\_ttc            |
| RUFL             | master                      | https://gitlab.cern.ch/arose/HGC-firmware        |
| GlobalCorrelator | thesps/vtx\_demo\_integration | https://github.com/thesps/GlobalCorrelator       |

##### Step 3: Create a PF+PUPPI Vivado project 
In the ipbb work area with the above packages cloned in the src dir, do:
For Serenity with KU15P daughter card:
```
ipbb proj create vivado pfpuppi_ku15p_vtx GlobalCorrelator:emp_examples/top -t top_dc_ku15p.dep
cd proj/pfpuppi_ku15p_vtx
```

##### Step 4: Setup, build and package the bitfile
Create the Vivado project
```
ipbb vivado make-project -c
```
(`-c`) for IP cache.
Then either 1): build the firmware in batch mode
```
ipbb vivado synth -j4 impl -j4
ipbb vivado package
```
Or 2): open the Vivado GUI
```
vivado top/top.xpr
```
