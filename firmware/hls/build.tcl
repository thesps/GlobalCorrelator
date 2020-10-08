open_project -reset add_hls
set_top add_hls
add_files add_hls.cpp
open_solution -reset "solution"
set_part {xcvu9p-flga2104-2L-e}
create_clock -period 2.7 -name default
csynth_design
export_design -format ip_catalog
exit
