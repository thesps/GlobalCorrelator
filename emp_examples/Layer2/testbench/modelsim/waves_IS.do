add wave sim:/top/clk
add wave sim:/top/Top/pairReduceLatency
add wave sim:/top/Top/inConeLatency
add wave sim:/top/Top/PFChargedObjIn
add wave -divider ObjsInt
add wave sim:/top/Top/ObjInt
add wave sim:/top/Top/rAddrs
add wave sim:/top/Top/ObjRead
add wave -divider ObjsIntWrite
add wave sim:/top/Top/wData
add wave sim:/top/Top/ObjWrite
add wave sim:/top/Top/wAddrs
add wave sim:/top/Top/wAddrsInt
add wave sim:/top/Top/wAddrExt
add wave sim:/top/Top/regMaxAddr
add wave sim:/top/Top/wEn
add wave sim:/top/Top/wEnInt
add wave -divider GlobalSeedSelection
add wave sim:/top/Top/newSeed
add wave sim:/top/Top/newSeedPipe
add wave sim:/top/Top/PairReduceIn
add wave sim:/top/Top/PairReduceOut
add wave sim:/top/Top/CurrentGlobalSeed
add wave -divider SeedCandidateComparison
add wave sim:/top/Top/deltaR2_arr
add wave sim:/top/Top/inCone
add wave -position insertpoint  \
sim:/top/Top/GenDR2(0)/dr2/a \
sim:/top/Top/GenDR2(0)/dr2/b \
sim:/top/Top/GenDR2(0)/dr2/q
