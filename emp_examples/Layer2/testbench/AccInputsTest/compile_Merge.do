set RUFL /vols/cms/ss5310/FW/work/src/HGC-firmware/projects/Common/firmware/hdl

vlib Simple
vlib Utilities
vlib Int

vmap Simple Simple
vmap Utilities Utilities
vmap Int Int

vcom -64 -2008 -work Utilities $RUFL/ReuseableElements/PkgUtilities.vhd
vcom -64 -2008 -work Utilities $RUFL/ReuseableElements/PkgDebug.vhd

vcom -64 -2008 -work Simple PkgSimple.vhd
vcom -64 -2008 -work Simple $RUFL/ReuseableElements/PkgArrayTypes.vhd
vcom -64 -2008 -work Simple $RUFL/ReuseableElements/Debugger.vhd
vcom -64 -2008 -work Simple $RUFL/ReuseableElements/DataPipe.vhd

vcom -64 -2008 -work Int ../../components/firmware/hdl/PkgInt.vhd
vcom -64 -2008 -work Int $RUFL/ReuseableElements/PkgArrayTypes.vhd

vcom -64 -2008 -work Simple ../../modules/firmware/hdl/RouterMerge16to32.vhd
vcom -64 -2008 -work Simple ../../modules/firmware/hdl/RouterMerge32to64.vhd
vcom -64 -2008 -work Simple ../../modules/firmware/hdl/RouterMerge32and64to64.vhd
vcom -64 -2008 -work Simple ../../modules/firmware/hdl/RouterMerge6x16to64.vhd

vcom -64 -2008 -work xil_defaultlib Testbench_merge.vhd
