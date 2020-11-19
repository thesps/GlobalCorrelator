# Endcap Correlator Layer 1 Demonstrator 

Repository to build firmware for a demonstrator of the Correlator Layer 1 in the endcap region (1.5 < |&eta;| < 2.5 for the moment, 2.5 < |&eta;| < 3.0 to be added later)

This uses the [git submodule](https://git-scm.com/docs/gitsubmodules) feature to get the dependencies, e.g. the PF & regionizer code.

## Quick instructions

* you should provide a `buildToolSetup.sh` to setup the environment for Vivado
* a project can be created with `./setupProject.sh project_name` (see below for the list of projects)
* then, one can compile the firmware with `./buildFirmware.sh project_name`

## Implemented Projects


### Regionizer-only designs

For all designs, PF runs with 9 phi regions with 0.25 rad overlap

#### `regionizer_mux`: simplest version

This is the simplest full regionizer algorithm
   * all inputs are at TM6, and are already in the 64 bit format (but muons are in local coordinates)
   * the tracker has 9 sectors, with 2 "fibers"/sector giving 1 track/clock, with sector-local  &eta;,&phi; coordinates
   * HGCal has 3 sectors with 4 fibers/sector giving 1 track/clock, with sector-local &eta;,&phi; coordinates
   * the muon system sends muons globally with 2 muons / clock, in global coordinates
   * the regionizer waits for 54 clocks to read all inputs, then outputs the sorted list of the best 30 tracks, 20 calo and muons for each region, sending out all objects of the region in parallel and keeping them stable for 6 clocks before moving on with the next region.

Resource usage (emp framework, payload):
|   Total LUTs  |   Logic LUTs  |   LUTRAMs   |    SRLs    |      FFs      |    RAMB36   |    RAMB18   |   URAM   | DSP48 Blocks |
|---------------|---------------|-------------|------------|---------------|-------------|-------------|----------|--------------|
|  52083(4.41%) |  52083(4.41%) |    0(0.00%) |   0(0.00%) | 110634(4.68%) |  132(6.11%) |    0(0.00%) | 0(0.00%) |     0(0.00%) |

#### `regionizer_stream`: stream outputs instead of just muxing them

This differs from `regionizer_mux` in only one simple aspect:  for each region, instead of outputing the sorted list of 30/20/4 tracks/calo/muons and keeping them constant for 6 clocks, it will stream the objects in those 6 clocks.
So, the output is 5 tracks, 4 calo, 1 muon per clock cycle.
 * At the 1st clock cycle of a region it will output: tracks 0, 6, 12, 18, 24; calo 0, 6, 12, 18; muon 0
 * At the 2nd clock cycle it will output: tracks 1, 7, 13, 19, 25; calo 1, 7, 13, 19; muon 1
 * At the 3rd clock cycle it will output: tracks 2, 8, 14, 20, 26; calo 2, 8, 14 plus one null calo; muon 2
 * At the 6th and last clock cycle it will output: tracks 5, 11, 17, 23, 29; calo 5, 11, 17 plus one null; a null muon

Resource usage (emp framework, payload):
|   Total LUTs  |   Logic LUTs  |   LUTRAMs   |    SRLs    |      FFs      |    RAMB36   |    RAMB18   |   URAM   | DSP48 Blocks |
|---------------|---------------|-------------|------------|---------------|-------------|-------------|----------|--------------|
|  53698(4.54%) |  53698(4.54%) |    0(0.00%) |   0(0.00%) | 105002(4.44%) |  132(6.11%) |    0(0.00%) | 0(0.00%) |     0(0.00%) |

### PF IP core designs

These are used to test the routing and timing for a single HLS IP core

#### `pf_360`: PF @ 360 MHz

This setup runs the PF block at full 360 MHz.
 * the IP core for PF can be build with `make_hls_cores.sh pfHGCal_2p2ns_ii6` (which runs `l1pf_hls/run_hls_pfalgo2hgc_2p2ns_II6.tcl`)

TODO:
 * the design has routing & timing issues, even when running with reduced inputs (20 tracks, 12 calo) and disabling the reset signal (which is a major offender in the timing)
 * the inputs & outputs are taken from the first N links, while picking them from a suitable set associated to quads in a same SLR would be better
 * the design is importing the IP core VHDL files directly instead of importing the core itself

#### `pf_240`: PF @ 240 MHz

This setup runs the PF block at 240 MHz by using dual-clock BRAM FIFOs to bridge the 360 to 240 MHz clock domains 
 * the IP core for PF can be build with `make_hls_cores.sh pfHGCal_3ns_ii4` (which runs `l1pf_hls/run_hls_pfalgo2hgc_3ns_II4.tcl`)
 * the design has routing & timing challenges, but it does succeeed when tying the reset signal to zero

Resource usage (emp framework, pf block only):
| Tk/Calo/Mu |   Total LUTs   |   Logic LUTs   |       FFs      |    RAMB36   |    RAMB18   |   URAM   | DSP48 Blocks  |
|------------|----------------|----------------|----------------|-------------|-------------|----------|---------------|
|  20/12/4   |  55768( 4.72%) |  51956( 4.39%) |   54380(2.30%) |    0(0.00%) |    3(0.07%) | 0(0.00%) |   312( 4.56%) |
|  30/20/4   | 127499(10.78%) | 119017(10.07%) |  117915(4.99%) |    0(0.00%) |    0(0.00%) | 0(0.00%) |   710(10.38%) |


TODO:
 * the inputs & outputs are taken from the first N links, while picking them from a suitable set associated to quads in a same SLR would be better
 * the design is importing the IP core VHDL files directly instead of importing the core itself


### Layer-1 designs

#### `regionizer_mux_pf_puppi`: `regionizer_mux` + PF@360 + Puppi@360

This setup runs the mux regionizer + the PF and Puppi at 360 MHz with II=6 (same clock as the regionizer)
 * the EMP input pattern files can be generated with `l1pf_hls/multififo_regionizer/run_hls_csim_pf_puppi.tcl`
 * the IP core for PF can be build with `make_hls_cores.sh pfHGCal_2p2ns_ii6` and `make_hls_cores.sh puppiHGCal_2p2ns_ii6`, which run `l1pf_hls/run_hls_pfalgo2hgc_2p2ns_II6.tcl` and `l1pf_hls/puppi/run_hls_linpuppi_hgcal_2p2ns_II6.tcl`

A vhdl testbench simulation in vivado can be run with `test/run_vhdltb.sh` run with `mux-pf-puppi` as argument.
 * The first PF & Puppi outputs arrive at frames 111 and 169 in the testbench output, compared to 54 in the reference from HLS (HLS has an ideal 54 clock cycle latency for the regionizer, to stream in the inputs, and zero latency for PF & Puppi)
 * For a reduced set of inputs (20 tracks, 12 calo) the frames become 106 and 153 for PF and puppi
 

TODO:
 * Implementation in the EMP framework has routing and timing problems
 * The design is somewhat wasteful in terms of resources for delaying the tracks & PV for puppi: it's using one BRAM36 for each track while in principle one could just use NTRACKS / II BRAMs, and uses a full BRAM36 for the PV Z where a BRAM18 would have been sufficient
 * The VHDL testbench uses the VHDL output files from the IP core synthesis directly instead of importing the IP core

#### `regionizer_stream_cdc_pf_puppi`: `regionizer_stream` +  PF@240 + Puppi@240


This setup runs the streaming regionizer at 360 MHz, transfers the data to the 240 MHz clock domain and runs the PF and Puppi with II=4, and then crosses the data back
 * the EMP input pattern files can be generated with `l1pf_hls/multififo_regionizer/run_hls_csim_pf_puppi.tcl`
 * the IP core for PF can be build with `make_hls_cores.sh pfHGCal_3ns_ii4` and `make_hls_cores.sh puppiHGCal_3ns_ii4`, which run `l1pf_hls/run_hls_pfalgo2hgc_3ns_II4.tcl` and `l1pf_hls/puppi/run_hls_linpuppi_hgcal_3ns_II4.tcl`
 * clock domain crossings are done with dual-clock BRAM36 used in native FIFO mode.
 * the reading of the output in the 360 MHz domain is synchronized to a delayed version of the start of writing inputs from the 360 MHz domain, so that the latency in the 360 MHz domain is fixed irrespectively of the phase between the two clocks and the time it takes to make the two clock domain crossings. The price for this is that the design is conservative on the latency, potentially waits a bit more before starting to read the outputs.

A vhdl testbench simulation in vivado can be run with `test/run_vhdltb.sh` run with `stream-cdc-pf-puppi` as argument.
 * The first PF & Puppi outputs arrive at frames 170 and 218 in the testbench output, compared to 54 in the reference from HLS (HLS has an ideal 54 clock cycle latency for the regionizer, to stream in the inputs, and zero latency for PF & Puppi)
 * For a reduced set of inputs (20 tracks, 12 calo) the frames become 163 and 203. 

Resource usage from emp framework, payload (might not be 100% up to date):
|  Tk/Calo/Mu  |   Total LUTs   |   Logic LUTs   |   LUTRAMs   |     SRLs    |       FFs      |    RAMB36   |    RAMB18   |   URAM   | DSP48 Blocks |
|--------------|----------------|----------------|-------------|-------------|----------------|-------------|-------------|----------|--------------|
|  30/20/4     | 245570(20.77%) | 236304(19.99%) |    0(0.00%) | 9266(1.57%) | 372574(15.76%) |  204(9.44%) |   10(0.23%) | 0(0.00%) | 1220(17.84%) |
|  20/12/4     | 124651(10.54%) | 120494(10.19%) |    0(0.00%) | 4157(0.70%) |  216147(9.14%) |  179(8.29%) |    9(0.21%) | 0(0.00%) |   530(7.75%) |

TODO:
 * Implementation in the EMP framework has routing and timing problems, but completes successfully for small number of inptus (20 track, 12 calo) and with no reset signals.
 * The design is somewhat wasteful in terms of resources for delaying objects (BRAM36s are used in all places, also when BRAM18 or shift registers would do)
 * The parallel FIFOs importing data in the 240 MHz are assumed to be all in phase, and so the 240 MHz processing starts as soon as one FIFO becomes readable. It may be safer to wait until all FIFOs are non-empty before staring to read.
 * There's a lot of code duplication for the various CDCs and serial to parallel transitions.
 * The VHDL testbench uses the VHDL output files from the IP core synthesis directly instead of importing the IP core.


#### `tdemux_regionizer_cdc_pf_puppi`: time demultiplexer + trivial decoder + `regionizer_stream` +  PF@240 + Puppi@240

This setup starts from `regionizer_stream_cdc_pf_puppi` and makes the inputs more realistic:
 * tracks come at TMUX 18 with 1 fiber per sector per time slice, and 3 input times slices (T0, T0+6, T0+12). Track objects are 96 bit long.
 * hgcal comes at TMUX 18 with 4 fiber per sector per time slice, and 3 input times slices (T0, T0+6, T0+12). Calo objects are 128 bit long, and arrive at 16 G so with 1 null word after 2 valid ones.
 * muons come at TMUX 18 with 1 fiber per time slice and 3 input time slices  (T0, T0+6, T0+12). Muons are 128 bit long.
In all cases the "longer" objects are made just by padding our existing 64 bit objecs with zeros so the decoding to 64 bit is trivial, but the decoding is anyway performed with an HLS IP core so a more complex version of it should be straightfoward to use.

Compared to `regionizer_stream_cdc_pf_puppi` : 
 * the EMP input pattern files can be generated with `l1pf_hls/multififo_regionizer/run_hls_csim_pf_puppi_tm18.tcl`
 * this needs additional IP cores that can be build with `make_hls_cores.sh tdemux` and `make_hls_cores.sh unpackers`.

A vhdl testbench simulation in vivado can be run with `test/run_vhdltb.sh` run with `tdemux-stream-cdc-pf-puppi` as argument.
 * For a reduced set of inputs (20 tracks, 12 calo), the only setup tested so far, the first PF & Puppi outputs arrive at frames 276 and 316 in the testbench output, compared to 54 in the reference from HLS (HLS has an ideal 54 clock cycle latency for the regionizer, to stream in the inputs, and zero latency for PF & Puppi). 


TODO:
 * Implementation in the EMP framework is not tested


