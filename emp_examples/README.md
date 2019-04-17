##### Step 1: Install ipbb

##### Step 2: Setup the emp work area
If you haven't already cloned the emp-fwk and related firmware somewhere else, then get the core components:

```
ipbb init p2fwk-work
cd p2fwk-work
git clone https://gitlab.cern.ch/p2-xware/firmware/emp-fwk.git -b tags/v0.2.5
git clone https://gitlab.cern.chcms-cactus/firmware/mp7.git -b ephemeral/phase2-vC
ipbb add git https://github.com/ipbus/ipbus-firmware -b tags/v1.3
```

##### Step 2: Build the PF+PUPPI HLS IP core

```
cd src
git clone https://github.com/violatingcp/GlobalCorrelator_HLS.git -b serenity
cd GlobalCorrelator_HLS
vivado_hls run_hls_fullpfalgo_w_puppi.tcl 
```

##### Step 3: Create a PF+PUPPI Vivado project 
Still in `p2fwk-work/src`
```
git clone https://github.com/thesps/GlobalCorrelator.git
```
For Serenity with KU115 SO1 daughter card:
```
ipbb proj create vivado pfpuppi_serenity_ku115 GlobalCorrelator:emp_examples/top -t top_dc_ku115_so1_pfp.dep
cd proj/pfpuppi_serenity_ku115
```

For VCU118 dev-kit (VU9P FPGA):
```
ipbb proj create vivado pfpuppi_vcu118 GlobalCorrelator:emp_examples/top -t top_vcu118_pfp.dep
cd proj/pfpuppi_vcu118
```

##### Step 4: Setup, build and package the bitfile
Create the Vivado project
```
ipbb vivado project
```
Then either 1): build the firmware in batch mode
```
ipbb vivado synth -j4 impl -j4
ipbb vivado package
```
Or 2): open the Vivado GUI
```
vivado top/top.xpr
```

##### Step 5: Run on the serenity

```
open vivado (lxplus)
connect to greg-special port : 3191
select remote server
choose digilent target the one with the KU115
program bitfile
ssh cmx@greg-usb2eth-2
source emp-toolbox/env.sh 
sudo /home/cmx/PCIe/uHAL/pcie_reconnect_xilinx.sh
export UHAL_ENABLE_IPBUS_PCIE=true
cd sioni_pf_test
./pf_pattern_file_test.sh
```

##### Helper: Serenity commands

```
cd ~/PCIe/uHAL/ipbus-software/uhal/Serenity/
source setup.sh
./bin/Power_OFF.exe ./etc/uhal/Serenity/serenity_connections.xml
./bin/Power_ON.exe ./etc/uhal/Serenity/serenity_connections.xml
Monitor
./bin/LTM4677_status.exe ./etc/uhal/Serenity/serenity_connections.xml 
./bin/SI5345.exe --c etc/uhal/Serenity/serenity_connections.xml --source ./SI5345_100MHz_settings.txt
./bin/NDM3Z_status.exe ./etc/uhal/Serenity/serenity_connections.xml
Program
./bin/jsm.exe --c ./etc/uhal/Serenity/serenity_connections.xml --source 1 --target 1

```



