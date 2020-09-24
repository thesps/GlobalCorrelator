import numpy as np
import random
random.seed(51091)

n_links_hgc_total = 12
n_regions_pf = 18

class LinkData:
    def __init__(self, data=0, addr=0, dataValid=False, frameValid=False, iRegion=0, string=None):
        if string is None:
            self.data = data
            self.addr = addr
            self.dataValid = dataValid
            self.frameValid = frameValid
            self.iRegion = iRegion
        else:
            d = string.split(',')
            self.data = int(d[0])
            self.addr = int(d[1])
            self.dataValid = True if d[2].lower() == 'true' else False
            self.frameValid = True if d[3].lower() == 'true' else False
            self.iRegion = int(d[4])

    def __str__(self):
        x = [self.data, self.addr, self.dataValid, self.frameValid, self.iRegion]
        x = [str(xi) for xi in x]
        return ','.join(x)

    def __repr__(self):
        return 'LinkData(' + str(self) + ')'

def parse_file(f):
    x = []
    lines = f.readlines()
    for line in lines:
        line = line.replace(' ', '').replace(';\n','')
        data = line.split(';')
        xi = [LinkData(string=di) for di in data]
        x.append(xi)
    return x

def write_line(f, x):
    f.write(';'.join([str(xi) for xi in x]) + '\n')

def empty_rows(f, n):
    for i in range(n):
        x = [LinkData() for j in range(n_links_hgc_total)]
        write_line(f, x)

def test_rand(f):
    ii = 1 # a unique ID
    # start with some rows of 0 data
    empty_rows(f, 4)
    # Now do 4 rows of random data
    for i in range(4):
        x = [LinkData(dataValid=True, frameValid=True) for j in range(n_links_hgc_total)]
        for j in range(n_links_hgc_total):
            x[j].data = ii
            ii += 1
            x[j].iRegion = random.randint(0, n_regions_pf-1)
        write_line(f, x)

    empty_rows(f, 4)

def test_simple(f):
    empty_rows(f, 4)
    x = []
    for i in range(4):
        x.append([LinkData(dataValid=False, frameValid=True) for j in range(n_links_hgc_total)])
    ii = 1
    for i in range(2):
        for j in range(2):
            x[i][j].dataValid = True
            x[i][j].iRegion = 1
            x[i][j].data = ii
            ii += 1
    for i in range(4):
        write_line(f, x[i])

    empty_rows(f, 4)

if __name__ == '__main__':
    f = open('SimulationInput.txt', 'w')
    test_simple(f)
