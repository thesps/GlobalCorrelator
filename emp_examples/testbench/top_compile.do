vlib modelsim_lib/xil_defaultlib
vlib modelsim_lib/Link
vlib modelsim_lib/Utilities
vlib modelsim_lib/Interfaces

vmap Utilities modelsim_lib/Utilities
vmap xil_defaultlib modelsim_lib/xil_defaultlib
vmap Link modelsim_lib/Link
vmap Interfaces modelsim_lib/Interfaces

vcom -64 -2008 -work Interfaces \
"./firmware/hdl/mp7_data_types.vhd" \
"../../../HGC-firmware/projects/Common/firmware/hdl/TopLevelInterfaces/PkgInterfaces.vhd" \

vcom -64 -2008 -work xil_defaultlib \
"../../../emp-fwk-v0.3.0/components/datapath/firmware/hdl/emp_data_types.vhd" \
"../top/firmware/hdl/ku15p_decl_sim.vhd" \

vcom -64 -2008 -work Utilities \
"../../../HGC-firmware/projects/Common/firmware/hdl/ReuseableElements/PkgUtilities.vhd" \
"../../../HGC-firmware/projects/Common/firmware/hdl/ReuseableElements/PkgDebug.vhd" \
"../../../HGC-firmware/projects/Common/firmware/hdl/TestingAndDebugging/MP7CaptureFileReader.vhd" \

vcom -64 -2008 -work Link \
"../wrapper/firmware/hdl/PkgLink.vhd" \
"../../../HGC-firmware/projects/Common/firmware/hdl/ReuseableElements/PkgArrayTypes.vhd" \
"../../../HGC-firmware/projects/Common/firmware/hdl/ReuseableElements/DataRam.vhd" \
"../../../HGC-firmware/projects/Common/firmware/hdl/ReuseableElements/Debugger.vhd" \

source ../PF_IP_II2_360MHz/firmware/cfg/PF_sim_compile.do

vcom -64 -2008 -work xil_defaultlib \
"../wrapper/firmware/hdl/pf_data_types.vhd" \
"../wrapper/firmware/hdl/pf_constants.vhd" \
"../wrapper/firmware/hdl/pf_ip_wrapper_42.vhd" \
"../wrapper/firmware/hdl/PatternFileLinkSync.vhd" \
"../wrapper/firmware/hdl/PF_top.vhd" \
"./firmware/hdl/DummyData.vhd" \
"./firmware/hdl/TestBench.vhd" \
