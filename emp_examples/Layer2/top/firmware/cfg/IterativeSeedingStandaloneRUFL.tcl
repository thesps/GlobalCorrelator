set SRCDIR "/vols/cms/ss5310/FW/work/src/GlobalCorrelator/emp_examples"
set RUFL "/vols/cms/ss5310/FW/work/src/HGC-firmware/projects/Common/firmware/hdl"
set RE $RUFL/ReuseableElements
set ComComp $SRCDIR/Common/components/firmware/hdl
set ComMod $SRCDIR/Common/modules/firmware/hdl
set L2Comp $SRCDIR/Layer2/components/firmware/hdl
set L2Mod $SRCDIR/Layer2/modules/firmware/hdl
set L2Top $SRCDIR/Layer2/top/firmware/hdl

file mkdir Layer2
file mkdir Utilities
file mkdir PFChargedObj 
file mkdir TDeltaR2

#add_files $L2Top/vcu118_decl_sim.vhd

add_files -force -copy_to Layer2 $L2Mod/IterativeSeeding.vhd $ComComp/PkgConstants.vhd $L2Comp/PkgIterativeSeeding.vhd $L2Mod/AllFlatRegionsToStreams.vhd L2Mod/FlatRegionsToStreams.vhd $L2Mod/LinkDecode.vhd $L2Mod/DebugSeedOut.vhd $L2Top/PFLayer2ProcessorTopIterativeSeeding.vhd
set_property library Layer2 [get_files -regexp {.*/Layer2/.*.vhd}]
set_property file_type {VHDL 2008} [get_files -regexp {.*/Layer2/.*.vhd}]

add_files -force -copy_to PFChargedObj $ComComp/PkgPFChargedObj.vhd $ComMod/ParallelToSerial.vhd $ComMod/DeltaR2.vhd $RE/PairReduceMax.vhd
add_files -force -copy_to PFChargedObj $RE/PkgArrayTypes.vhd $RE/DataPipe.vhd $RE/Debugger.vhd
set_property library PFChargedObj [get_files -regexp {.*/PFChargedObj/.*.vhd}]
set_property file_type {VHDL 2008} [get_files -regexp {.*/PFChargedObj/.*.vhd}]

add_files -force -copy_to Utilities $RE/PkgUtilities.vhd $RE/PkgDebug.vhd 
set_property library Utilities [get_files -regexp {.*/Utilities/.*.vhd}]
set_property file_type {VHDL 2008} [get_files -regexp {.*/Utilities/.*.vhd}]

add_files -force -copy_to TDeltaR2 $ComComp/PkgDeltaR2.vhd $RE/PkgArrayTypes.vhd
set_property library TDeltaR2 [get_files -regexp {.*/TDeltaR2/.*.vhd}]
set_property file_type {VHDL 2008} [get_files -regexp {.*/TDeltaR2/.*.vhd}]

set_property library xil_defaultlib [get_files payload.vhd]
