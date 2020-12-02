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
|  52209(4.42%) |  51912(4.39%) |    0(0.00%) | 297(0.05%) | 111220(4.70%) |  132(6.11%) |    0(0.00%) | 0(0.00%) |     0(0.00%) |

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
|  53822(4.55%) |  53525(4.53%) |    0(0.00%) | 297(0.05%) | 106097(4.49%) |  132(6.11%) |    0(0.00%) | 0(0.00%) |     0(0.00%) |

### PF IP core designs

These are used to test the routing and timing for a single HLS IP core

#### `pf_360`: PF @ 360 MHz

This setup runs the PF block at full 360 MHz.
 * the IP core for PF can be build with `make_hls_cores.sh pfHGCal_2p2ns_ii6` (which runs `l1pf_hls/run_hls_pfalgo2hgc_2p2ns_II6.tcl`)

|  Instance  |  Total LUTs  |  Logic LUTs  |   LUTRAMs   |     SRLs    |      FFs      |   RAMB36  |    RAMB18   |   URAM   | DSP48 Blocks |
|------------|--------------|--------------|-------------|-------------|---------------|-----------|-------------|----------|--------------|
| top        | 89199(7.54%) | 81938(6.93%) | 1754(0.30%) | 5507(0.93%) | 113139(4.78%) | 96(4.44%) | 896(20.74%) | 0(0.00%) |   440(6.43%) |
|   payload  | 39331(3.33%) | 34268(2.90%) |    0(0.00%) | 5063(0.86%) |  60076(2.54%) |  0(0.00%) |    0(0.00%) | 0(0.00%) |   440(6.43%) |

TODO:
 * the design has routing & timing issues, even when running with reduced inputs (20 tracks, 12 calo) and disabling the reset signal (which is a major offender in the timing)
 * the design is importing the IP core VHDL files directly instead of importing the core itself

#### `pf_240`: PF @ 240 MHz

This setup runs the PF block at 240 MHz by using dual-clock BRAM FIFOs to bridge the 360 to 240 MHz clock domains 
 * the IP core for PF can be build with `make_hls_cores.sh pfHGCal_240MHz_ii4` (which runs `l1pf_hls/run_hls_pfalgo2hgc_3ns_II4.tcl`)
 * the design has routing & timing challenges, but it does succeeed when tying the reset signal to zero. 
 * IP core latency: 41 clock

Resource usage (emp framework)
|  Instance  |   Total LUTs   |   Logic LUTs   |   LUTRAMs   |     SRLs     |      FFs      |   RAMB36   |    RAMB18   |   URAM   | DSP48 Blocks |
|------------|----------------|----------------|-------------|--------------|---------------|------------|-------------|----------|--------------|
| top        | 136370(11.53%) | 123866(10.48%) | 1754(0.30%) | 10750(1.82%) | 165943(7.02%) | 124(5.74%) | 896(20.74%) | 0(0.00%) |  750(10.96%) |
|   payload  |   86489(7.32%) |   76183(6.44%) |    0(0.00%) | 10306(1.74%) | 112880(4.77%) |  28(1.30%) |    0(0.00%) | 0(0.00%) |  750(10.96%) |

TODO:
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
 * the IP core for PF can be build with `make_hls_cores.sh pfHGCal_240MHz_ii4` and `make_hls_cores.sh puppiHGCal_240MHz_ii4`, which run `l1pf_hls/run_hls_pfalgo2hgc_3ns_II4.tcl` and `l1pf_hls/puppi/run_hls_linpuppi_hgcal_3ns_II4.tcl`
 * clock domain crossings are done with dual-clock BRAM36 used in native FIFO mode.
 * the reading of the output in the 360 MHz domain is synchronized to a delayed version of the start of writing inputs from the 360 MHz domain, so that the latency in the 360 MHz domain is fixed irrespectively of the phase between the two clocks and the time it takes to make the two clock domain crossings. The price for this is that the design is conservative on the latency, potentially waits a bit more before starting to read the outputs.

A vhdl testbench simulation in vivado can be run with `test/run_vhdltb.sh` run with `stream-cdc-pf-puppi` as argument.
 * The first PF & Puppi outputs arrive at frames 185 and 233 in the testbench output, compared to 54 in the reference from HLS (HLS has an ideal 54 clock cycle latency for the regionizer, to stream in the inputs, and zero latency for PF & Puppi)

Resource usage from emp framework:
|  Instance  |   Total LUTs   |   Logic LUTs   |   LUTRAMs   |     SRLs     |       FFs      |    RAMB36   |    RAMB18   |   URAM   | DSP48 Blocks |
|------------|----------------|----------------|-------------|--------------|----------------|-------------|-------------|----------|--------------|
| top        | 252272(21.34%) | 238213(20.15%) | 1754(0.30%) | 12305(2.08%) | 404120(17.09%) | 300(13.89%) | 906(20.97%) | 0(0.00%) | 1245(18.20%) |
|   payload  | 202393(17.12%) | 190532(16.12%) |    0(0.00%) | 11861(2.00%) | 351057(14.85%) |  204(9.44%) |   10(0.23%) | 0(0.00%) | 1245(18.20%) |

TODO:
 * Implementation in the EMP framework does not meet timing, but we know that e.g. the input link assignment to quads is not good (this is fixed in the later designs).
 * The design is somewhat wasteful in terms of resources for delaying objects
 * The parallel FIFOs importing data in the 240 MHz are assumed to be all in phase, and so the 240 MHz processing starts as soon as one FIFO becomes readable. It may be safer to wait until all FIFOs are non-empty before staring to read.
 * There's a lot of code duplication for the various CDCs and serial to parallel transitions (this is somewhat reduced in the later designs)
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
 * For a reduced set of inputs (20 tracks, 12 calo), the first PF & Puppi outputs arrive at frames 276 and 316 in the testbench output, compared to 54 in the reference from HLS (HLS has an ideal 54 clock cycle latency for the regionizer, to stream in the inputs, and zero latency for PF & Puppi). 
 * For the full set of inputs (30 tracks, 20 calo) and the longer latency PF block (B), the first PF & Puppi outputs arrive at frames 297 and 345 in the testbench output, compared to 54 in the reference from HLS (HLS has an ideal 54 clock cycle latency for the regionizer, to stream in the inputs, and zero latency for PF & Puppi). This estimate of the latency is largely conservative, as it's using the latency of the traditional Puppi algorithm which is longer.

Resource usage from emp framework:

|  Instance  |   Total LUTs   |   Logic LUTs   |   LUTRAMs   |     SRLs     |       FFs      |    RAMB36   |    RAMB18   |   URAM   | DSP48 Blocks |
|------------|----------------|----------------|-------------|--------------|----------------|-------------|-------------|----------|--------------|
| top        | 264567(22.38%) | 250508(21.19%) | 1754(0.30%) | 12305(2.08%) | 435270(18.41%) | 366(16.94%) | 906(20.97%) | 0(0.00%) | 1245(18.20%) |
|   payload  | 214672(18.16%) | 202811(17.15%) |    0(0.00%) | 11861(2.00%) | 382207(16.16%) | 270(12.50%) |   10(0.23%) | 0(0.00%) | 1245(18.20%) |

TODO:
 * Implementation in the EMP framework does not meet timing


#### `tdemux_regionizer_cdc_pf_puppi_stream`: time demultiplexer + trivial decoder + `regionizer_stream` +  PF@240 + Puppi stream@240

The change wrt `tdemux_regionizer_cdc_pf_puppi` is that it uses a streaming implementation of Puppi, with 3 components: 
 * a chs component that takes a single PF charged candidate and the PV, computes the compatibility and returns in output the PF candidate charged or zero
 * a prepare component that takes as input a track and the PV, and saves an object with pt, eta and a weight equal to pt^2 if the track is PV-compatible and zero otherwise
 * a neutral component that takes as input a single PF neutral candidate and a list of objects from the prepare above, and outputs the puppi candidate (or a null candidate)
all the components are pipelined at II=1.

The whole Puppi logic is implemented with the above 3:
 * PF Charged particles serialized into NTrack/II streams and are then processed by a set of parallell instances of the "chs" component before being inputed in the CDC logic
 * A copy of the input tracks is made before the serial-to-parallel conversion, and they delayed and then processed by the prepare component, and then converted from serial to parallel
 * PF neutral particles are serialized, and then processed together with the prepared objects before going into the CDC logic  

The implementation requires to compile the new cores for the streaming puppi with  `make_hls_cores.sh puppiHGCal_240MHz_stream` 

A VHDL testbench implementation can be run with  `run_vhdltb.sh tdemux-stream2-cdc-pf-puppi`:
 * For the full set of inputs (30 tracks, 20 calo) and the longer latency PF block (B), the first PF & Puppi outputs arrive at frames 297 and 345 in the testbench output, compared to 54 in the reference from HLS (HLS has an ideal 54 clock cycle latency for the regionizer, to stream in the inputs, and zero latency for PF & Puppi). This estimate of the latency is largely conservative, as it's using the latency of the traditional Puppi algorithm which is longer.

Resource usage from emp framework:
|  Instance  |   Total LUTs   |   Logic LUTs   |   LUTRAMs   |     SRLs     |       FFs      |    RAMB36   |    RAMB18   |   URAM   | DSP48 Blocks |
|------------|----------------|----------------|-------------|--------------|----------------|-------------|-------------|----------|--------------|
| top        | 216875(18.34%) | 202242(17.11%) | 1754(0.30%) | 12879(2.18%) | 378775(16.02%) | 344(15.93%) | 981(22.71%) | 0(0.00%) | 1223(17.88%) |
|   payload  | 166943(14.12%) | 154508(13.07%) |    0(0.00%) | 12435(2.10%) | 325713(13.78%) | 248(11.48%) |   85(1.97%) | 0(0.00%) | 1223(17.88%) |

TODO:
 * possibly recover some clock cycles
 * investigate and solve the timing pulse width failure in the PCIexpress


