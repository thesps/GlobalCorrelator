#!/bin/bash
if [[ "$1" == "" ]]; then echo "Usage : $0 project"; exit 1; fi;

REG_VHDL="../l1pf_hls/multififo_regionizer/vhdl/firmware/hdl"
REG_VHDLTB="../l1pf_hls/multififo_regionizer/vhdl/firmware/testbench"

DEMO_VHDL="../demonstrator_firmware/firmware/hdl"

HLS_CSIM="../l1pf_hls/multififo_regionizer/project_csim_pf_puppi"
VHDLS=""

if [[ "$1" == "mux-pf" ]]; then
    CORES="pfHGCal_2p2ns_ii6"

    VHDLS="${VHDLS} ${REG_VHDL}/regionizer_data.vhd ${REG_VHDL}/rolling_fifo.vhd ${REG_VHDL}/fifo_merge2.vhd ${REG_VHDL}/fifo_merge2_full.vhd ${REG_VHDL}/fifo_merge3.vhd ${REG_VHDL}/stream_sort.vhd ${REG_VHDL}/region_mux.vhd"
    VHDLS="${VHDLS} ${REG_VHDL}/tk_router_element.vhd ${REG_VHDL}/tk_router.vhd ${REG_VHDL}/tk_regionizer.vhd "
    VHDLS="${VHDLS} ${REG_VHDL}/calo_router.vhd ${REG_VHDL}/calo_regionizer.vhd "
    VHDLS="${VHDLS} ${REG_VHDL}/mu_router.vhd ${REG_VHDL}/mu_regionizer.vhd "
    VHDLS="${VHDLS} ${REG_VHDL}/full_regionizer_mux.vhd"
    VHDLS="${VHDLS} ${REG_VHDLTB}/pattern_textio.vhd"
    VHDLS="${VHDLS} ${DEMO_VHDL}/regionizer_mux_pf.vhd "
    VHDLS="${VHDLS} regionizer_mux_pf_tb.vhd"
elif [[ "$1" == "mux-pf-puppi" ]]; then
    CORES="pfHGCal_2p2ns_ii6 puppiHGCal_2p2ns_ii6_charged  puppiHGCal_2p2ns_ii6_neutral"

    VHDLS="${VHDLS} ${REG_VHDL}/regionizer_data.vhd ${REG_VHDL}/rolling_fifo.vhd ${REG_VHDL}/fifo_merge2.vhd ${REG_VHDL}/fifo_merge2_full.vhd ${REG_VHDL}/fifo_merge3.vhd ${REG_VHDL}/stream_sort.vhd ${REG_VHDL}/region_mux.vhd"
    VHDLS="${VHDLS} ${REG_VHDL}/tk_router_element.vhd ${REG_VHDL}/tk_router.vhd ${REG_VHDL}/tk_regionizer.vhd "
    VHDLS="${VHDLS} ${REG_VHDL}/calo_router.vhd ${REG_VHDL}/calo_regionizer.vhd "
    VHDLS="${VHDLS} ${REG_VHDL}/mu_router.vhd ${REG_VHDL}/mu_regionizer.vhd "
    VHDLS="${VHDLS} ${REG_VHDL}/full_regionizer_mux.vhd"
    VHDLS="${VHDLS} ${REG_VHDLTB}/pattern_textio.vhd"
    VHDLS="${VHDLS} ${DEMO_VHDL}/bram_delay.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/regionizer_mux_pf_puppi.vhd "
    VHDLS="${VHDLS} regionizer_mux_pf_puppi_tb.vhd"
elif [[ "$1" == "stream-cdc-pf-puppi" ]]; then
    CORES="pfHGCal_3ns_ii4 puppiHGCal_3ns_ii4_charged  puppiHGCal_3ns_ii4_neutral"

    VHDLS="${VHDLS} ${REG_VHDL}/regionizer_data.vhd ${REG_VHDL}/rolling_fifo.vhd ${REG_VHDL}/fifo_merge2.vhd ${REG_VHDL}/fifo_merge2_full.vhd ${REG_VHDL}/fifo_merge3.vhd ${REG_VHDL}/stream_sort.vhd ${REG_VHDL}/region_mux_stream.vhd"
    VHDLS="${VHDLS} ${REG_VHDL}/tk_router_element.vhd ${REG_VHDL}/tk_router.vhd ${REG_VHDL}/tk_regionizer.vhd "
    VHDLS="${VHDLS} ${REG_VHDL}/calo_router.vhd ${REG_VHDL}/calo_regionizer.vhd "
    VHDLS="${VHDLS} ${REG_VHDL}/mu_router.vhd ${REG_VHDL}/mu_regionizer.vhd "
    VHDLS="${VHDLS} ${REG_VHDL}/full_regionizer_mux_stream.vhd"
    VHDLS="${VHDLS} ${REG_VHDLTB}/pattern_textio.vhd"
    VHDLS="${VHDLS} ${DEMO_VHDL}/bram_delay.vhd  ${DEMO_VHDL}/bit_delay.vhd ${DEMO_VHDL}/cdc_bram_fifo.vhd  ${DEMO_VHDL}/serial2parallel.vhd ${DEMO_VHDL}/parallel2serial.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/regionizer_mux_stream_cdc_pf_puppi.vhd "
    VHDLS="${VHDLS} regionizer_mux_stream_cdc_pf_puppi_tb.vhd"
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
#rm -r xsim* xelab* webtalk* xvhdl* test.wdb 2> /dev/null || true;

echo " ## Compiling IP cores VHDL files: $CORES";
for C in $CORES; do
    test -d ../ip_cores_firmware/$C || echo "Missing IP core $C; use make_hls_cores.sh in the main directory to generate it"
    test -d ../ip_cores_firmware/$C || exit 2; 
    for F in $(awk '/^src/{print $2}' ../ip_cores_firmware/$C/firmware/cfg/top.dep); do 
        xvhdl ../ip_cores_firmware/$C/firmware/hdl/$F || exit 2;
        grep -q ERROR xvhdl.log && exit 2;
    done;
done

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
