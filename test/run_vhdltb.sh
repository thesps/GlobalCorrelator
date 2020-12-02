#!/bin/bash
if [[ "$1" == "" ]]; then echo "Usage : $0 project"; exit 1; fi;

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


if [[ "$1" == "mux-pf-puppi" ]]; then
    CORES="pfHGCal_360MHz_ii6 puppiHGCal_360MHz_ii6_charged  puppiHGCal_360MHz_ii6_neutral"
    VHDLS="${VHDLS} ${DEMO_VHDL}/bram_delay.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/pf_block_wrapper.vhd ${DEMO_VHDL}/puppich_block_wrapper.vhd  ${DEMO_VHDL}/puppine_block_wrapper.vhd"
    VHDLS="${VHDLS} ${DEMO_VHDL}/regionizer_mux_pf_puppi.vhd "
    VHDLS="${VHDLS} regionizer_mux_pf_puppi_tb.vhd"
elif [[ "$1" == "stream-cdc-pf-puppi" ]]; then
    CORES="pfHGCal_240MHz_ii4 puppiHGCal_240MHz_ii4_charged  puppiHGCal_240MHz_ii4_neutral"

    VHDLS="${VHDLS} ${DEMO_VHDL}/bram_delay.vhd ${DEMO_VHDL}/bit_delay.vhd ${DEMO_VHDL}/cdc_bram_fifo.vhd  ${DEMO_VHDL}/serial2parallel.vhd ${DEMO_VHDL}/parallel2serial.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/pf_block_wrapper.vhd ${DEMO_VHDL}/puppich_block_wrapper.vhd  ${DEMO_VHDL}/puppine_block_wrapper.vhd"
    VHDLS="${VHDLS} ${DEMO_VHDL}/stream_pf_puppi_240.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/cdc_and_deserializer.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/regionizer_mux_stream_cdc_pf_puppi.vhd "
    VHDLS="${VHDLS} regionizer_mux_stream_cdc_pf_puppi_tb.vhd"
elif [[ "$1" == "tdemux-stream-cdc-pf-puppi" ]]; then
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
elif [[ "$1" == "tdemux-stream2-cdc-pf-puppi" ]]; then
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


CSIM=${HLS_CSIM}/solution/csim/build
if test -f $CSIM/input-emp.txt; then
    echo " ## Getting C simulation inputs from $CSIM";
    cp -v $CSIM/*-emp*.txt .
else
    echo "Couldn't find C simulation inputs in $CSIM.";
    echo "Run vivado_hls in the parent directory before.";
    exit 1;
fi;

# cleanup
if [[ "$2" != "retry" ]]; then
    rm -r xsim* xelab* webtalk* xvhdl* test.wdb 2> /dev/null || true;

    echo " ## Compiling IP cores VHDL files: $CORES";
    CORES_SRC=../ip_cores_firmware
    for C in $CORES; do
        test -d ${CORES_SRC}/$C || echo "Missing IP core $C; use make_hls_cores.sh in the main directory to generate it"
        test -d ${CORES_SRC}/$C || exit 2; 
        for F in $(awk '/^src/{print $2}' ${CORES_SRC}/$C/firmware/cfg/top.dep); do 
            xvhdl ${CORES_SRC}/$C/firmware/hdl/$F || exit 2;
            grep -q ERROR xvhdl.log && exit 2;
        done;
    done
fi;

echo " ## Compiling VHDL files: $VHDLS";
for V in $VHDLS; do
    xvhdl ${V} || exit 2;
    grep -q ERROR xvhdl.log && exit 2;
done;

echo " ## Elaborating: ";
xelab testbench -s test -debug all  || exit 3;
grep -q ERROR xelab.log && exit 3;

echo " ## Running simulation in batch mode: ";
xsim test -R || exit 4;
grep -q ERROR xsim.log && exit 4;
