set RUFL "/home/sioni/Work/p2fwk-work/src/HGC-firmware/projects/Common/firmware/hdl/ReuseableElements"

add_files ./PkgSimple.vhd
add_files $RUFL/PkgArrayTypes.vhd
add_files $RUFL/DataPipe.vhd

add_files ../../modules/firmware/hdl/RouterMerge16to32.vhd
add_files ../../modules/firmware/hdl/RouterMerge32to64.vhd
add_files ../../modules/firmware/hdl/RouterMerge32and64to64.vhd
add_files ../../modules/firmware/hdl/RouterMerge6x16to64.vhd
add_files ../../modules/firmware/hdl/RouterAccumulate64to128.vhd
add_files ../../modules/firmware/hdl/RouterMergeAccumulateInputs.vhd
add_files ../../modules/firmware/hdl/UniqueRouting.vhd

set_property library Simple [get_files -regexp {.*.vhd}]

add_files $RUFL/PkgUtilities.vhd

set_property library Utilities [get_files -regexp {.*PkgUtilities.vhd}]

add_files ../../components/firmware/hdl/PkgInt.vhd
add_files -force -copy_to IntLib $RUFL/PkgArrayTypes.vhd

set_property library Int [get_files -regexp {.*PkgInt.vhd}]
set_property library Int [get_files -regexp {.*/IntLib/.*}]

add_files top_merge.vhd


set_property FILE_TYPE {VHDL 2008} [get_files *.vhd]
