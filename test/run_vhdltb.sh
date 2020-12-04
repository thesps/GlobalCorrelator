#!/bin/bash

SIMULATOR="xsim";
if [[ "$1" == "-vsim" ]]; then SIMULATOR=vsim; shift; fi;
if [[ "$1" == "-xsim" ]]; then SIMULATOR=xsim; shift; fi;

if which $SIMULATOR > /dev/null 2>&1; then
    echo "Will use $SIMULATOR";

    if [[ "${SIMULATOR}" == "vsim" ]] && [ \! -d xilinx_sim_lib/unisim ] ; then
        echo "Didn't find xilinx_sim_lib directory (or missing unisim library)"
        echo "run make_xilinx_sim_lib.sh to create it here, or symlink the ipbb one here."
        exit 2;
    fi;
else
    echo "Couldn't find simulator $SIMULATOR. exiting"; 
    exit 1;
fi;

if [[ "$1" == "" ]]; then 
    echo "Usage : $0 [-xsim | -vsim] project [retry]"; 
    exit 1; 
fi;
PROJ=$1; shift;


REG_VHDL="../l1pf_hls/multififo_regionizer/vhdl/firmware/hdl/"
REG_VHDLTB="../l1pf_hls/multififo_regionizer/vhdl/firmware/testbench"

DEMO_VHDL="../demonstrator_firmware/firmware/hdl"

HLS_CSIM="../l1pf_hls/multififo_regionizer/project_csim_pf_puppi"
VHDLS=""

## Preload the regionizer files
for F in $( awk '/src/{print $2}' ${REG_VHDL}/../cfg/regionizer.dep ); do
    VHDLS="${VHDLS} ${REG_VHDL}/$F";
done
VHDLS="${VHDLS} ${REG_VHDLTB}/pattern_textio.vhd"


if [[ "${PROJ}" == "mux-pf-puppi" ]]; then
    CORES="pfHGCal_360MHz_ii6 puppiHGCal_360MHz_ii6_charged  puppiHGCal_360MHz_ii6_neutral"
    VHDLS="${VHDLS} ${DEMO_VHDL}/bram_delay.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/pf_block_wrapper.vhd ${DEMO_VHDL}/puppich_block_wrapper.vhd  ${DEMO_VHDL}/puppine_block_wrapper.vhd"
    VHDLS="${VHDLS} ${DEMO_VHDL}/regionizer_mux_pf_puppi.vhd "
    VHDLS="${VHDLS} regionizer_mux_pf_puppi_tb.vhd"
elif [[ "${PROJ}" == "stream-cdc-pf-puppi" ]]; then
    CORES="pfHGCal_240MHz_ii4 puppiHGCal_240MHz_ii4_charged  puppiHGCal_240MHz_ii4_neutral"

    VHDLS="${VHDLS} ${DEMO_VHDL}/bram_delay.vhd ${DEMO_VHDL}/bit_delay.vhd ${DEMO_VHDL}/cdc_bram_fifo.vhd  ${DEMO_VHDL}/serial2parallel.vhd ${DEMO_VHDL}/parallel2serial.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/pf_block_wrapper.vhd ${DEMO_VHDL}/puppich_block_wrapper.vhd  ${DEMO_VHDL}/puppine_block_wrapper.vhd"
    VHDLS="${VHDLS} ${DEMO_VHDL}/stream_pf_puppi_240.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/cdc_and_deserializer.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/regionizer_mux_stream_cdc_pf_puppi.vhd "
    VHDLS="${VHDLS} regionizer_mux_stream_cdc_pf_puppi_tb.vhd"
elif [[ "${PROJ}" == "tdemux-stream-cdc-pf-puppi" ]]; then
    CORES="pfHGCal_240MHz_ii4 puppiHGCal_240MHz_ii4_charged  puppiHGCal_240MHz_ii4_neutral tdemux unpackers"

    VHDLS="${VHDLS} ${DEMO_VHDL}/bram_delay.vhd ${DEMO_VHDL}/bit_delay.vhd ${DEMO_VHDL}/cdc_bram_fifo.vhd  ${DEMO_VHDL}/serial2parallel.vhd ${DEMO_VHDL}/parallel2serial.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/tdemux_link_group.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/tracker_tdemux_decode_regionizer.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/hgcal_tdemux_decode_regionizer.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/muon_tdemux_decode_regionizer.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/pf_block_wrapper.vhd ${DEMO_VHDL}/puppich_block_wrapper.vhd  ${DEMO_VHDL}/puppine_block_wrapper.vhd"
    VHDLS="${VHDLS} ${DEMO_VHDL}/stream_pf_puppi_240.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/cdc_and_deserializer.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/tdemux_regionizer_cdc_pf_puppi.vhd "
    VHDLS="${VHDLS} tdemux_regionizer_cdc_pf_puppi_tb.vhd"
    HLS_CSIM="../l1pf_hls/multififo_regionizer/project_csim_pf_puppi_tm18"
elif [[ "${PROJ}" == "tdemux-stream2-cdc-pf-puppi" ]]; then
    CORES="pfHGCal_240MHz_ii4 puppiHGCal_240MHz_stream_prep puppiHGCal_240MHz_stream_one puppiHGCal_240MHz_stream_chs tdemux unpackers"

    VHDLS="${VHDLS} ${DEMO_VHDL}/bram_delay.vhd ${DEMO_VHDL}/bit_delay.vhd ${DEMO_VHDL}/word_delay.vhd ${DEMO_VHDL}/cdc_bram_fifo.vhd  ${DEMO_VHDL}/serial2parallel.vhd ${DEMO_VHDL}/parallel2serial.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/tdemux_link_group.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/tracker_tdemux_decode_regionizer.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/hgcal_tdemux_decode_regionizer.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/muon_tdemux_decode_regionizer.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/pf_block_wrapper.vhd ${DEMO_VHDL}/puppine_one_block_wrapper.vhd"
    VHDLS="${VHDLS} ${DEMO_VHDL}/stream_pf_puppi_one_240.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/cdc_and_deserializer.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/tdemux_regionizer_cdc_pf_puppi.vhd "
    VHDLS="${VHDLS} tdemux_regionizer_cdc_pf_puppi_tb.vhd"
    HLS_CSIM="../l1pf_hls/multififo_regionizer/project_csim_pf_puppi_tm18"

fi

if [[ "$1" == "retry" ]]; then
    if [ \! -d ${PROJ}_${SIMULATOR}.dir ]; then echo  "Missing ${PROJ}_${SIMULATOR}.dir"; exit 1; fi;
else
    if [ -d ${PROJ}_${SIMULATOR}.dir ]; then
        echo "Deleting existing ${PROJ}_${SIMULATOR}.dir;"
        rm -r ${PROJ}_${SIMULATOR}.dir || exit 1;
    fi;
    mkdir ${PROJ}_${SIMULATOR}.dir || exit 1;
fi;
cd ${PROJ}_${SIMULATOR}.dir || exit 1;


CSIM=../${HLS_CSIM}/solution/csim/build
if test -f $CSIM/input-emp.txt; then
    echo " ## Getting C simulation inputs from $CSIM";
    cp -v $CSIM/*-emp*.txt . 
else
    echo "Couldn't find C simulation inputs in $CSIM.";
    echo "Run vivado_hls to generate them before.";
fi;

# cleanup
if [[ "$1" != "retry" ]]; then
    if [[ "${SIMULATOR}" == "vsim" ]]; then
        vlib work
        vmap work ${PWD}/work

        vmap unisim $PWD/../xilinx_sim_lib/unisim
        sed -i -e 's/; *StdArithNoWarnings = 1/StdArithNoWarnings = 1/' -e 's/; *NumericStdNoWarnings = 1/NumericStdNoWarnings = 1/' modelsim.ini
    fi;

    echo " ## Compiling IP cores VHDL files: $CORES";
    CORES_SRC=../../ip_cores_firmware
    for C in $CORES; do
        test -d ${CORES_SRC}/$C || echo "Missing IP core $C; use make_hls_cores.sh in the main directory to generate it"
        test -d ${CORES_SRC}/$C || exit 2; 
        for F in $(awk '/^src/{print $2}' ${CORES_SRC}/$C/firmware/cfg/top.dep); do 
            case $SIMULATOR in
                xsim) xvhdl --2008 ${CORES_SRC}/$C/firmware/hdl/$F || exit 2;;
                vsim) echo " - $C : $F"; vcom -2008 -source -quiet ${CORES_SRC}/$C/firmware/hdl/$F || exit 2;;
            esac;
        done;
    done
else
    if [[ "${SIMULATOR}" == "xsim" ]]; then
        rm -r {xsim,xelab,xvhdl,webtalk,vivado}*{log,jou}* test.wdb 2> /dev/null || true;
    fi;
fi;


echo " ## Compiling VHDL files: $VHDLS";
for V in $VHDLS; do
    case $SIMULATOR in
        xsim) xvhdl ../${V} || exit 2;;
        vsim) echo " - ../$V"; vcom -2008 -source -quiet ../${V} || exit 2;;
    esac;
done;

case $SIMULATOR in
    xsim) 
        echo " ## Elaborating: ";
        xelab testbench -s test -debug all  || exit 3;
        echo " ## Running simulation in batch mode: ";
        xsim test -R || exit 4;
        ;;
    vsim)
        echo " ## Running simulation in batch mode: ";
        vsim work.testbench -t ps -batch -do "run -all"
        ;;
esac;

echo "Output is in ${PROJ}_${SIMULATOR}.dir"
