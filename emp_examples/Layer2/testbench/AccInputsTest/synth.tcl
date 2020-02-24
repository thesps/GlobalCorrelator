set RUFL "/vols/cms/ss5310/FW/work/src/HGC-firmware/projects/Common/firmware/hdl/ReuseableElements"

add_files ./PkgSimple.vhd
add_files $RUFL/PkgArrayTypes.vhd

add_files ../../modules/firmware/hdl/RouterAccumulateInputs.vhd
add_files ../../modules/firmware/hdl/UniqueRouting.vhd

set_property library Simple [get_files -regexp {.*.vhd}]

add_files $RUFL/PkgUtilities.vhd

set_property library Utilities [get_files -regexp {.*PkgUtilities.vhd}]

add_files ../../components/firmware/hdl/PkgInt.vhd
add_files -force -copy_to IntLib $RUFL/PkgArrayTypes.vhd

set_property library Int [get_files -regexp {.*PkgInt.vhd}]
set_property library Int [get_files -regexp {.*/IntLib/.*}]

set_property FILE_TYPE {VHDL 2008} [get_files *.vhd]
