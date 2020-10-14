#!/bin/bash

RUFL=../../../../../RuflCore
RE=$RUFL/firmware/hdl/ReuseableElements

MODULES=../../modules/firmware/hdl
COMPONENTS=../../components/firmware/hdl
L2COMPONENTS=../../../Layer2/components/firmware/hdl
COMMON=../../../Common
INT=$COMMON/Int/firmware/hdl
BOOL=$COMMON/Bool/firmware/hdl

vlib libs/HGCRouter
vmap HGCRouter libs/HGCRouter

vlib libs/xil_defaultlib
vmap xil_defaultlib libs/xil_defaultlib

vlib libs/Utilities
vmap Utilities libs/Utilities

vlib libs/Int
vmap Int libs/Int

vlib libs/Bool
vmap Bool libs/Bool

vcom -2008 -work Utilities $RE/PkgUtilities.vhd
vcom -2008 -work Utilities $RE/PkgDebug.vhd

vcom -2008 -work Int $INT/PkgInt.vhd
vcom -2008 -work Int $INT/PkgArrayTypes.vhd
vcom -2008 -work Int $INT/DataPipe.vhd
vcom -2008 -work Int $INT/Debugger.vhd

vcom -2008 -work Bool $BOOL/PkgBool.vhd
vcom -2008 -work Bool $BOOL/PkgArrayTypes.vhd

vcom -2008 -work xil_defaultlib $COMPONENTS/PkgConstants.vhd

vcom -2008 -work HGCRouter $COMPONENTS/PkgHGCAbstractRouter.vhd
vcom -2008 -work HGCRouter $RE/PkgArrayTypes.vhd
vcom -2008 -work HGCRouter $RE/DataPipe.vhd
vcom -2008 -work HGCRouter $RE/DataRam.vhd
vcom -2008 -work HGCRouter $MODULES/DistributionServer.vhd
vcom -2008 -work HGCRouter $RE/Debugger.vhd
vcom -2008 -work HGCRouter $MODULES/RegionBuffer.vhd
vcom -2008 -work HGCRouter $MODULES/RegionBuffers.vhd

vcom -2008 -work HGCRouter $COMPONENTS/PkgFindIndexInRow.vhd
vcom -2008 -work HGCRouter $MODULES/Router.vhd

vcom -2008 -work xil_defaultlib SimulationInput.vhd
vcom -2008 -work xil_defaultlib SimulationOutput.vhd
vcom -2008 -work xil_defaultlib RegionizerTestbench.vhd
