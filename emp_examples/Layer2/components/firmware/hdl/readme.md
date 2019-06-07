# Regions
For a first pass, region IDs are generated as :
```
x = np.arange(0, 72, 1).reshape(8, 9)
array([[ 0,  1,  2,  3,  4,  5,  6,  7,  8],
       [ 9, 10, 11, 12, 13, 14, 15, 16, 17],
       [18, 19, 20, 21, 22, 23, 24, 25, 26],
       [27, 28, 29, 30, 31, 32, 33, 34, 35],
       [36, 37, 38, 39, 40, 41, 42, 43, 44],
       [45, 46, 47, 48, 49, 50, 51, 52, 53],
       [54, 55, 56, 57, 58, 59, 60, 61, 62],
       [63, 64, 65, 66, 67, 68, 69, 70, 71]])

```
i.e. 8x9 regions in (eta, phi). So each board in a 4-eta-slice configuration maps to consecutive IDs.
This will have to change if the ordering of the region processing in Layer1 changes.

The neighbouring IDs are found like, allowing wrap around in phi but not eta (using -1 when there is no neighbour):
```
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
```
Giving, e.g. for the neighbours of (eta, phi) = (0, 0):
`[-1, -1, -1, 8, 0, 1, 17, 9, 10]`
Visualised as:
```
[[-1, -1, -1],
 [ 8,  0,  1],
 [17,  9, 10]]
```
