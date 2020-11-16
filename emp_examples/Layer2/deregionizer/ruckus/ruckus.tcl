# Load local source Code and constraints
loadSource -lib "IO" -dir "$::DIR_PATH/../firmware/hdl/"
loadSource -lib "IO" -dir "$::DIR_PATH/../../IO/firmware/hdl/"
loadSource -lib "IO" -path "$::DIR_PATH/../../components/firmware/hdl/PkgIO.vhd"
loadSource -lib "Int" -path "$::DIR_PATH/../../components/firmware/hdl/PkgInt.vhd"
loadSource -lib "Int" -path "$::DIR_PATH/../../Int/firmware/hdl/PkgArrayTypes.vhd"

