# Endcap Correlator Layer 1 Demonstrator 

Repository to build firmware for a demonstrator of the Correlator Layer 1 in the endcap region (1.5 < |&eta;| < 2.5 for the moment, 2.5 < |&eta;| < 3.0 to be added later)

This uses the [git submodule](https://git-scm.com/docs/gitsubmodules) feature to get the dependencies, e.g. the PF & regionizer code.

## Quick instructions

* you should provide a `buildToolSetup.sh` to setup the environment for Vivado
* a project can be created with `./setupProject.sh project_name` (see below for the list of projects)
* then, one can compile the firmware with `./buildFirmware.sh project_name`

## Implemented Projects


### regionizer-only designs

For all designs, PF runs with 9 phi regions with 0.25 rad overlap

#### `regionizer_mux`: simplest version

This is the simplest full regionizer algorithm
   * all inputs are at TM6, and are already in the 64 bit format (but muons are in local coordinates)
   * the tracker has 9 sectors, with 2 "fibers"/sector giving 1 track/clock, with sector-local  &eta;,&phi; coordinates
   * HGCal has 3 sectors with 4 fibers/sector giving 1 track/clock, with sector-local &eta;,&phi; coordinates
   * the muon system sends muons globally with 2 muons / clock, in global coordinates
   * the regionizer waits for 54 clocks to read all inputs, then outputs the sorted list of the best 30 tracks, 20 calo and muons for each region, sending out all objects of the region in parallel and keeping them stable for 6 clocks before moving on with the next region.

Resource usage (emp framework, payload)
|   Total LUTs  |   Logic LUTs  |   LUTRAMs   |    SRLs    |      FFs      |    RAMB36   |    RAMB18   |   URAM   | DSP48 Blocks |
|---------------|---------------|-------------|------------|---------------|-------------|-------------|----------|--------------|
|  52083(4.41%) |  52083(4.41%) |    0(0.00%) |   0(0.00%) | 110634(4.68%) |  132(6.11%) |    0(0.00%) | 0(0.00%) |     0(0.00%) |

#### `regionizer_stream`: stream outputs instead of just muxing them

NOTE: the EMP wrapper for this is still missing

This differs from `regionizer_mux` in only one simple aspect:  for each region, instead of outputing the sorted list of 30/20/4 tracks/calo/muons and keeping them constant for 6 clocks, it will stream the objects in those 6 clocks.
So, the output is 5 tracks, 4 calo, 1 muon per clock cycle.
 * At the 1st clock cycle of a region it will output: tracks 0, 6, 12, 18, 24; calo 0, 6, 12, 18; muon 0
 * At the 2nd clock cycle it will output: tracks 1, 7, 13, 19, 25; calo 1, 7, 13, 19; muon 1
 * At the 3rd clock cycle it will output: tracks 2, 8, 14, 20, 26; calo 2, 8, 14 plus one null calo; muon 2
 * At the 6th and last clock cycle it will output: tracks 5, 11, 17, 23, 29; calo 5, 11, 17 plus one null; a null muon

