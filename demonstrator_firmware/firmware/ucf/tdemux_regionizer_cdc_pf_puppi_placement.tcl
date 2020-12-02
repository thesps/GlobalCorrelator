# define PBlocks for super-logic-regions
create_pblock pb_slr0 
resize_pblock pb_slr0 -add CLOCKREGION_X0Y0:CLOCKREGION_X5Y4
create_pblock pb_slr1 
resize_pblock pb_slr1 -add CLOCKREGION_X0Y5:CLOCKREGION_X5Y9
create_pblock pb_slr2 
resize_pblock pb_slr2 -add CLOCKREGION_X0Y10:CLOCKREGION_X5Y14

add_cells_to_pblock pb_slr2 "payload/algo_payload/calo_tdemux_decode_regionizer"
add_cells_to_pblock pb_slr0 "payload/algo_payload/tk_tdemux_decode_regionizer"
add_cells_to_pblock pb_slr0 "payload/algo_payload/mu_tdemux_decode_regionizer"
add_cells_to_pblock pb_slr1 "payload/algo_payload/pf_puppi_240"
