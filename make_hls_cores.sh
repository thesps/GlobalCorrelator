#!/bin/bash

if [[ "$1" == "" ]]; then echo "Usage : $0 core"; exit 1; fi;
core=$1
test -d ip_cores_firmware || mkdir ip_cores_firmware

case $core in
    pfHGCal_3ns_ii4)
        test -d ip_cores_firmware/$core && rm -r ip_cores_firmware/$core 2> /dev/null;
        mkdir -p ip_cores_firmware/$core/firmware/{hdl,cfg} &&
        pushd l1pf_hls &&
            (test -d proj_pfHGCal_VCU118_3ns_II4 || vivado_hls -f run_hls_pfalgo2hgc_3ns_II4.tcl) &&
            popd &&
        cp -v l1pf_hls/proj_pfHGCal_VCU118_3ns_II4/solution/impl/vhdl/* ip_cores_firmware/$core/firmware/hdl/ &&
        (cd ip_cores_firmware/$core/firmware/hdl && ls -1 ) | sed 's/^/src /' | tee ip_cores_firmware/$core/firmware/cfg/top.dep;
        ;;
    puppiHGCal_3ns_ii4)
        test -d ip_cores_firmware/${core}_charged && rm -r ip_cores_firmware/${core}_{charged,neutral} 2> /dev/null;
        mkdir -p ip_cores_firmware/${core}_{charged,neutral}/firmware/{hdl,cfg} &&
        pushd l1pf_hls/puppi &&
            (test -d l1pf_hls/puppi/proj_linpuppi_HGCal_VCU118_3ns_II4_charged || vivado_hls -f run_hls_linpuppi_hgcal_3ns_II4.tcl ) &&
            popd &&
        for X in charged neutral; do
            cp -v l1pf_hls/puppi/proj_linpuppi_HGCal_VCU118_3ns_II4_${X}/solution/impl/vhdl/* ip_cores_firmware/${core}_${X}/firmware/hdl/ &&
            (cd ip_cores_firmware/${core}_${X}/firmware/hdl && ls -1 ) | sed 's/^/src /' | tee ip_cores_firmware/${core}_${X}/firmware/cfg/top.dep;
        done
        ;;
    pfHGCal_2p2ns_ii6)
        test -d ip_cores_firmware/$core && rm -r ip_cores_firmware/$core 2> /dev/null;
        mkdir -p ip_cores_firmware/$core/firmware/{hdl,cfg} &&
        pushd l1pf_hls &&
            (test -d proj_pfHGCal_VCU118_2p2ns_II6 || vivado_hls -f run_hls_pfalgo2hgc_2p2ns_II6.tcl) &&
            popd &&
        cp -v l1pf_hls/proj_pfHGCal_VCU118_2p2ns_II6/solution/impl/vhdl/* ip_cores_firmware/$core/firmware/hdl/ &&
        (cd ip_cores_firmware/$core/firmware/hdl && ls -1 ) | sed 's/^/src /' | tee ip_cores_firmware/$core/firmware/cfg/top.dep;
        ;;
    puppiHGCal_2p2ns_ii6)
        test -d ip_cores_firmware/${core}_charged && rm -r ip_cores_firmware/${core}_{charged,neutral} 2> /dev/null;
        mkdir -p ip_cores_firmware/${core}_{charged,neutral}/firmware/{hdl,cfg} &&
        pushd l1pf_hls/puppi &&
            (test -d l1pf_hls/puppi/proj_linpuppi_HGCal_VCU118_2p2ns_II6_charged || vivado_hls -f run_hls_linpuppi_hgcal_2p2ns_II6.tcl ) &&
            popd &&
        for X in charged neutral; do
            cp -v l1pf_hls/puppi/proj_linpuppi_HGCal_VCU118_2p2ns_II6_${X}/solution/impl/vhdl/* ip_cores_firmware/${core}_${X}/firmware/hdl/ &&
            (cd ip_cores_firmware/${core}_${X}/firmware/hdl && ls -1 ) | sed 's/^/src /' | tee ip_cores_firmware/${core}_${X}/firmware/cfg/top.dep;
        done
        ;;
esac;
