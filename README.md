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
 * `regionizer_mux`: 
   * all inputs are at TM6, and are already in the 64 bit format (but muons are in local coordinates)
   * the tracker has 9 sectors, with 2 "fibers"/sector giving 1 track/clock, with sector-local  &eta;,&phi; coordinates
   * HGCal has 3 sectors with 4 fibers/sector giving 1 track/clock, with sector-local &eta;,&phi; coordinates
   * the muon system sends muons globally with 2 muons / clock, in global coordinates
   * the regionizer waits for 54 clocks to read all inputs, then outputs the sorted list of the best 30 tracks, 20 calo and muons for each region, sending out all objects of the region in parallel and keeping them stable for 6 clocks before moving on with the next region.
