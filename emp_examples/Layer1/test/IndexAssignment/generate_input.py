import numpy as np
import random
random.seed(51091)

n_links_hgc_total = 12
n_regions_pf = 18

class data:
    def __init__(self, data=0, addr=0, dataValid=False, frameValid=False, iRegion=0):
        self.data = data
        self.addr = addr
        self.dataValid = dataValid
        self.frameValid = frameValid
        self.iRegion = iRegion

    def __str__(self):
        x = [self.data, self.addr, self.dataValid, self.frameValid, self.iRegion]
        x = [str(xi) for xi in x]
        return ','.join(x)

if __name__ == '__main__':
    f = open('SimulationInput.txt', 'w')
    ii = 1 # a unique ID
    # start with some rows of 0 data
    for i in range(4):
        x = [str(data()) for j in range(n_links_hgc_total)]
        f.write(';'.join(x) + '\n')

    # Now do 4 rows of random data
    for i in range(4):
        x = [data(dataValid=True, frameValid=True) for j in range(n_links_hgc_total)]
        for j in range(n_links_hgc_total):
            x[j].data = ii
            ii += 1
            x[j].iRegion = random.randint(0, n_regions_pf-1)
        x = [str(xi) for xi in x]
        f.write(';'.join(x) + '\n')

    # end with some rows of 0 data
    for i in range(4):
        x = [str(data()) for j in range(n_links_hgc_total)]
        f.write(';'.join(x) + '\n')

