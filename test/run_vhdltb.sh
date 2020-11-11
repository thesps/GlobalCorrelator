#!/bin/bash
if [[ "$1" == "" ]]; then echo "Usage : $0 project"; exit 1; fi;

PF_FILES="
calc_dptscale_525_s_p_dr2max_times_pterr2.vhd
calc_dptscale_525_s.vhd
dr2_dpt_int_cap.vhd
dr2_int_cap_12_s.vhd
mu2trk_dptvals.vhd
mu2trk_linkstep.vhd
mutrk_link.vhd
packed_pfalgo2hgc_am_submul_10s_10s_22_2_0.vhd
packed_pfalgo2hgc_mul_mul_15ns_15ns_25_2_0.vhd
packed_pfalgo2hgc_mul_mul_16ns_16ns_32_2_1.vhd
packed_pfalgo2hgc_mul_mul_16s_16s_32_2_1.vhd
packed_pfalgo2hgc_mul_mul_17ns_25ns_42_2_0.vhd
packed_pfalgo2hgc_mux_305_10_1_1.vhd
packed_pfalgo2hgc_mux_305_16_1_1.vhd
pfmualgo.vhd
pick_closest.vhd
tk2calo_caloalgo_hgc.vhd
tk2calo_drdptvals.vhd
tk2calo_elealgo_hgc.vhd
tk2calo_link_drdpt.vhd
tk2calo_sumtk_hgc.vhd
tk2calo_tkalgo_hgc.vhd
pfalgo2hgc.vhd
packed_pfalgo2hgc.vhd
"
PF240_FILES="
calc_dptscale_525_s_p_dr2max_times_pterr2.vhd
calc_dptscale_525_s.vhd
dr2_dpt_int_cap.vhd
dr2_int_cap_12_s.vhd
mu2trk_dptvals.vhd
mu2trk_linkstep.vhd
mutrk_link.vhd
packed_pfalgo2hgc_am_submul_10s_10s_22_1_0.vhd
packed_pfalgo2hgc_mul_mul_15ns_15ns_25_1_0.vhd
packed_pfalgo2hgc_mul_mul_16ns_16ns_32_1_1.vhd
packed_pfalgo2hgc_mul_mul_16s_16s_32_1_1.vhd
packed_pfalgo2hgc_mul_mul_17ns_25ns_42_1_0.vhd
packed_pfalgo2hgc_mux_305_10_1_1.vhd
packed_pfalgo2hgc_mux_305_16_1_1.vhd
packed_pfalgo2hgc.vhd
pfalgo2hgc.vhd
pfmualgo.vhd
pick_closest.vhd
tk2calo_caloalgo_hgc.vhd
tk2calo_drdptvals.vhd
tk2calo_elealgo_hgc.vhd
tk2calo_link_drdpt.vhd
tk2calo_sumtk_hgc.vhd
tk2calo_tkalgo_hgc.vhd
"

PUPPI_FILES="
dr2_int.vhd
fwdlinpuppi_calc_wpt_table_V.vhd
fwdlinpuppi_calc_wpt.vhd
fwdlinpuppi_calc_x2a_table1_V.vhd
fwdlinpuppi_calc_x2a.vhd
linpuppi_fromPV.vhd
linpuppiSum2All.vhd
packed_linpuppiNoCrop_ama_submuladd_10s_10s_22s_22_2_0.vhd
packed_linpuppiNoCrop_am_submul_10s_10s_22_2_0.vhd
packed_linpuppiNoCrop_mul_mul_16s_16s_32_2_1.vhd
packed_linpuppiNoCrop_mul_mul_16s_6ns_22_2_1.vhd
packed_linpuppiNoCrop_mul_mul_17ns_16ns_32_2_1.vhd
packed_linpuppiNoCrop_mul_mul_9ns_16s_24_2_1.vhd
p_lut_shift15_divide_p_table_V.vhd
p_lut_shift15_divide.vhd
linpuppiNoCrop.vhd
packed_linpuppiNoCrop.vhd
"

PUPPI240_FILES="
dr2_int.vhd
fwdlinpuppi_calc_wpt_table_V.vhd
fwdlinpuppi_calc_wpt.vhd
fwdlinpuppi_calc_x2a_table1_V.vhd
fwdlinpuppi_calc_x2a.vhd
linpuppi_fromPV.vhd
linpuppiNoCrop.vhd
linpuppiSum2All.vhd
packed_linpuppiNoCrop_ama_submuladd_10s_10s_22s_22_1_0.vhd
packed_linpuppiNoCrop_am_submul_10s_10s_22_1_0.vhd
packed_linpuppiNoCrop_mul_mul_16s_16s_32_1_1.vhd
packed_linpuppiNoCrop_mul_mul_16s_6ns_22_1_1.vhd
packed_linpuppiNoCrop_mul_mul_17ns_16ns_32_1_1.vhd
packed_linpuppiNoCrop_mul_mul_9ns_16s_24_1_1.vhd
packed_linpuppiNoCrop.vhd
p_lut_shift15_divide_p_table_V.vhd
p_lut_shift15_divide.vhd
"

PUPPICHS_FILES="
linpuppi_fromPV.vhd
linpuppi_chs.vhd
packed_linpuppi_chs.vhd
"

REG_VHDL="../l1pf_hls/multififo_regionizer/vhdl/firmware/hdl"
REG_VHDLTB="../l1pf_hls/multififo_regionizer/vhdl/firmware/testbench"

DEMO_VHDL="../demonstrator_firmware/firmware/hdl"

HLS_CSIM="../l1pf_hls/multififo_regionizer/project_csim_pf_puppi"
VHDLS=""
if [[ "$1" == "mux-pf" ]]; then
    PF_DIR="../l1pf_hls/proj_pfHGCal_VCU118_2.5ns_II6/solution/impl/vhdl"
    for F in ${PF_FILES}; do VHDLS="${VHDLS} ${PF_DIR}/$F"; done

    VHDLS="${VHDLS} ${REG_VHDL}/regionizer_data.vhd ${REG_VHDL}/rolling_fifo.vhd ${REG_VHDL}/fifo_merge2.vhd ${REG_VHDL}/fifo_merge2_full.vhd ${REG_VHDL}/fifo_merge3.vhd ${REG_VHDL}/stream_sort.vhd ${REG_VHDL}/region_mux.vhd"
    VHDLS="${VHDLS} ${REG_VHDL}/tk_router_element.vhd ${REG_VHDL}/tk_router.vhd ${REG_VHDL}/tk_regionizer.vhd "
    VHDLS="${VHDLS} ${REG_VHDL}/calo_router.vhd ${REG_VHDL}/calo_regionizer.vhd "
    VHDLS="${VHDLS} ${REG_VHDL}/mu_router.vhd ${REG_VHDL}/mu_regionizer.vhd "
    VHDLS="${VHDLS} ${REG_VHDL}/full_regionizer_mux.vhd"
    VHDLS="${VHDLS} ${REG_VHDLTB}/pattern_textio.vhd"
    VHDLS="${VHDLS} ${DEMO_VHDL}/regionizer_mux_pf.vhd "
    VHDLS="${VHDLS} regionizer_mux_pf_tb.vhd"
elif [[ "$1" == "mux-pf-puppi" ]]; then
    PF_DIR="../l1pf_hls/proj_pfHGCal_VCU118_2.5ns_II6/solution/impl/vhdl"
    PUPPI_DIR="../l1pf_hls/puppi/proj_linpuppi_HGCal_VCU118_2.5ns_II6/solution/impl/vhdl"
    PUPPICHS_DIR="../l1pf_hls/puppi/proj_linpuppi_HGCal_VCU118_2.5ns_II6_chs/solution/impl/vhdl"

    for F in ${PF_FILES}; do VHDLS="${VHDLS} ${PF_DIR}/$F"; done
    for F in ${PUPPI_FILES}; do VHDLS="${VHDLS} ${PUPPI_DIR}/$F"; done
    for F in ${PUPPICHS_FILES}; do VHDLS="${VHDLS} ${PUPPICHS_DIR}/$F"; done

    VHDLS="${VHDLS} ${REG_VHDL}/regionizer_data.vhd ${REG_VHDL}/rolling_fifo.vhd ${REG_VHDL}/fifo_merge2.vhd ${REG_VHDL}/fifo_merge2_full.vhd ${REG_VHDL}/fifo_merge3.vhd ${REG_VHDL}/stream_sort.vhd ${REG_VHDL}/region_mux.vhd"
    VHDLS="${VHDLS} ${REG_VHDL}/tk_router_element.vhd ${REG_VHDL}/tk_router.vhd ${REG_VHDL}/tk_regionizer.vhd "
    VHDLS="${VHDLS} ${REG_VHDL}/calo_router.vhd ${REG_VHDL}/calo_regionizer.vhd "
    VHDLS="${VHDLS} ${REG_VHDL}/mu_router.vhd ${REG_VHDL}/mu_regionizer.vhd "
    VHDLS="${VHDLS} ${REG_VHDL}/full_regionizer_mux.vhd"
    VHDLS="${VHDLS} ${DEMO_VHDL}/bram_delay.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/regionizer_mux_pf_puppi.vhd "
    VHDLS="${VHDLS} ${REG_VHDLTB}/pattern_textio.vhd"
    VHDLS="${VHDLS} regionizer_mux_pf_puppi_tb.vhd"
elif [[ "$1" == "stream-cdc-pf-puppi" ]]; then
    PF_DIR="../l1pf_hls/proj_pfHGCal_VCU118_3ns_II4/solution/impl/vhdl"
    PUPPI_DIR="../l1pf_hls/puppi/proj_linpuppi_HGCal_VCU118_3ns_II4_neutral/solution/impl/vhdl"
    PUPPICHS_DIR="../l1pf_hls/puppi/proj_linpuppi_HGCal_VCU118_3ns_II4_charged/solution/impl/vhdl"

    for F in ${PF240_FILES}; do VHDLS="${VHDLS} ${PF_DIR}/$F"; done
    for F in ${PUPPI240_FILES}; do VHDLS="${VHDLS} ${PUPPI_DIR}/$F"; done
    for F in ${PUPPICHS_FILES}; do VHDLS="${VHDLS} ${PUPPICHS_DIR}/$F"; done

    VHDLS="${VHDLS} ${REG_VHDL}/regionizer_data.vhd ${REG_VHDL}/rolling_fifo.vhd ${REG_VHDL}/fifo_merge2.vhd ${REG_VHDL}/fifo_merge2_full.vhd ${REG_VHDL}/fifo_merge3.vhd ${REG_VHDL}/stream_sort.vhd ${REG_VHDL}/region_mux_stream.vhd"
    VHDLS="${VHDLS} ${REG_VHDL}/tk_router_element.vhd ${REG_VHDL}/tk_router.vhd ${REG_VHDL}/tk_regionizer.vhd "
    VHDLS="${VHDLS} ${REG_VHDL}/calo_router.vhd ${REG_VHDL}/calo_regionizer.vhd "
    VHDLS="${VHDLS} ${REG_VHDL}/mu_router.vhd ${REG_VHDL}/mu_regionizer.vhd "
    VHDLS="${VHDLS} ${REG_VHDL}/full_regionizer_mux_stream.vhd"
    VHDLS="${VHDLS} ${DEMO_VHDL}/bram_delay.vhd ${DEMO_VHDL}/cdc_bram_fifo.vhd  ${DEMO_VHDL}/serial2parallel.vhd ${DEMO_VHDL}/parallel2serial.vhd "
    VHDLS="${VHDLS} ${DEMO_VHDL}/regionizer_mux_stream_cdc_pf_puppi.vhd "
    VHDLS="${VHDLS} ${REG_VHDLTB}/pattern_textio.vhd"
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

echo " ## Compiling VHDL files: $VHDLS";
for V in $VHDLS; do
    xvhdl ${V} || exit 2;
    grep -q ERROR xvhdl.log && exit 2;
done;

echo " ## Elaborating: ";
xelab testbench -s test -debug all || exit 3;
grep -q ERROR xelab.log && exit 3;

echo " ## Running simulation in batch mode: ";
xsim test -R || exit 4;
grep -q ERROR xsim.log && exit 4;
