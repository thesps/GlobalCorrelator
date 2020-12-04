#!/bin/bash
if [[ "$1" == "" ]]; then
    echo "Usage: $0 project";
    exit 1;
fi;
PROJECT=$1;
shift

if [ -f buildToolSetup.sh ] ; then
    source buildToolSetup.sh
fi

if [ -z ${XILINX_VIVADO:+x} ] ; then
    echo "Xilinx Vivado environment has not been sourced. Exiting."
    exit 1
else
    echo "Found Xilinx Vivado at" ${XILINX_VIVADO}
fi

if [ -d ipbb-0.5.2 ]; then
    echo "Will not re-download ipbb"
else 
    curl -L https://github.com/ipbus/ipbb/archive/v0.5.2.tar.gz | tar xvz
fi
source ipbb-0.5.2/env.sh

if [ -d algo-work ]; then
    echo "Using existing algo-work directory"
else
    ipbb init algo-work
    pushd algo-work
        ipbb add git https://:@gitlab.cern.ch:8443/p2-xware/firmware/emp-fwk.git -b v0.3.6
        ipbb add git https://gitlab.cern.ch/ttc/legacy_ttc.git -b v2.1
        ipbb add git https://github.com/ipbus/ipbus-firmware -b v1.8
        pushd src 
            ln -sd ../../l1pf_hls/multififo_regionizer .
            ln -sd ../../demonstrator_firmware .
            ln -sd ../../ip_cores_firmware .
        popd
    popd
fi


if test -f algo-work/src/demonstrator_firmware/firmware/cfg/${PROJECT}_top.dep; then
    echo "Will create a project for $PROJECT";
else
    echo "Couldn't find demonstrator_firmware/firmware/cfg/${PROJECT}_top.dep --> exiting";
    exit 1;
fi;

pushd algo-work
    test -d proj/$PROJECT && rm -rf proj/$PROJECT 
    ipbb proj create vivado $PROJECT demonstrator_firmware: -t ${PROJECT}_top.dep
    pushd proj/$PROJECT
        ipbb vivado project 
        #if test -f demonstrator_firmware/firmware/cfg/${PROJECT}_importIP.tcl then
        #vivado -mode batch -source ../../../$PROJECT/$HLSIP/importIP.tcl
        #end if
    popd
popd


