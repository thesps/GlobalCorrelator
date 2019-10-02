rm PF.dep
touch PF.dep
for f in `ls ../hdl`
do
  echo "src $f" >> PF.dep
done
