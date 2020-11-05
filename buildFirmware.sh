#!/bin/bash
if [[ "$1" == "" ]]; then
    echo "Usage: $0 project [what]";
    exit 1;
fi;
if [ \! -d algo-work/proj/$1 ]; then
    echo "Can't find project $1 under algo-work/proj";
    exit 1;
fi;

if [ -f buildToolSetup.sh ] ; then
    source buildToolSetup.sh
fi

if [ -z ${XILINX_VIVADO:+x} ] ; then
    echo "Xilinx Vivado environment has not been sourced. Exiting."
    exit 1
fi

source ipbb-0.5.2/env.sh

cd algo-work/proj/$1
shift;

WHAT=$1; if [[ "$1" == "" ]]; then WHAT="all"; fi;
case $WHAT in
s) 
    ipbb vivado synth -j4
    ;;
i)
    ipbb vivado impl -j4
    ;;
b)
    ipbb vivado package
    ;;
all)
    ipbb vivado synth -j4 impl -j4
    ipbb vivado resource-usage
    ipbb vivado package
    ;;
*)
    ipbb vivado $*
    ;;
esac;
