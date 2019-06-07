import numpy as np

x = np.arange(0, 72, 1).reshape(8, 9)

neighbours = []
for i in range(8):
  for j in range(9):
    ns = []
    for k in range(-1, 2):
      for l in range(-1, 2):
        eta = i + k
        phi = (j + l) % 9
        n = -1 if eta < 0 or eta > 7 else x[eta, phi]
        ns.append(n)
    neighbours.append(ns)

neighbours = np.array(neighbours)

data = '((' + "),\n(".join([', '.join(n.astype('str')) for n in neighbours]) + '))'
with open("NeighboursMap.txt", "w") as f:
  f.write(data)
  f.close()
