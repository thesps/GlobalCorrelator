# Description
Directory with `emp-fwk` project setups for 'standalone' pieces of the firmware chain.
Used for unit testing of timing closure of individual modules. 

## Index Assignment
Project for the module which assigns the address to input links based on its order in the regions, targetting VCU118.
```
ipbb proj create vivado CorrelatorL1_StandaloneIndexAssignment GlobalCorrelator:emp_examples/Layer1/standalones/IndexAssignment -t top.dep
ipbb vivado project -c
ipbb vivado synth -j8 impl -j8
```

## Index Assignment + Router
Project for the module which assigns the address to input links based on its order in the regions, then routes each index to separate streams, targetting VCU118.
```
ipbb proj create vivado CorrelatorL1_StandaloneIdxAssgnRouter GlobalCorrelator:emp_examples/Layer1/standalones/Router -t top.dep
ipbb vivado project -c
ipbb vivado synth -j8 impl -j8
```

## Regionizer: Index Assignment + Router + Event Buffer
Project for the full regionizer steps, including the above two projects, feeding into a final array of memories which buffer the event.
```
ipbb proj create vivado CorrelatorL1_StandaloneRegionizer GlobalCorrelator:emp_examples/Layer1/standalones/Regionizer -t top.dep
ipbb vivado project -c
ipbb vivado synth -j8 impl -j8
```

