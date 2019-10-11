rm PF.dep
touch PF.dep
rm PF_sim_compile.do
touch PF_sim_compile.do

for f in `ls ../hdl`
do
  echo "src $f" >> PF.dep
  echo "vcom -64 -2008 -work xil_defaultlib \"`pwd`/../hdl/$f\"" >> PF_sim_compile.do 
done


