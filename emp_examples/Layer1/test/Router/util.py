import numpy as np
import random
random.seed(51091)

n_links_hgc_total = 12
n_regions_pf = 18
n_inputs_pf = 20

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

    def __eq__(self, other):
        eq = True
        eq = eq and self.data == other.data
        eq = eq and self.addr == other.addr
        eq = eq and self.dataValid == other.dataValid
        eq = eq and self.frameValid == other.frameValid
        eq = eq and self.iRegion == other.iRegion
        return eq

def algo_ref(data2d):
    '''
    A reference implementation of the index assignment module.
    Input data "data2d" should be a 2D array of LinkData.
    The first dimension is treated as the "time" axis, and the second the "link" axis.
    The array is modified in place, with the address added to each element.
    '''
    # extract just the region field
    regions = np.array(list(map(lambda x : x.iRegion, data2d.flatten()))).reshape(data2d.shape)
    dv = np.array(list(map(lambda x : x.dataValid, data2d.flatten()))).reshape(data2d.shape)
    fv = np.array(list(map(lambda x : x.frameValid, data2d.flatten()))).reshape(data2d.shape)
    base = np.zeros(n_regions_pf, dtype='int')

    #for reg_row, dv_row in zip(regions, dv):
    for i in range(len(data2d)):
        reg_row, dv_row, fv_row, data_row = regions[i], dv[i], fv[i], data2d[i]
        # For each index i, count the instances of row[i] to the left
        indexInRow = np.array([sum(reg_row[:i] == reg_row[i]) for i in range(n_links_hgc_total)])
        # Put the index for invalid data to 0
        indexInRow[~dv_row] = 0

        # Reset the region base address between events
        if ~fv_row.all():
            base = np.zeros(n_regions_pf, dtype='int')

        for i, data in enumerate(data_row):
            data.addr = indexInRow[i] + base[reg_row[i]]
        # Count the instances of each region (valid data only)
        c, u = np.unique(reg_row[dv_row], return_counts=True)
        # Increment the region base counter
        base[c] += u
    return data2d

def valid_frames(data2d):
    '''
    Slice the rows from data2d where all links have frameValid=True
    '''
    frameValid = np.array(list(map(lambda x : x.frameValid, data2d.flatten()))).reshape(data2d.shape).all(axis=1)
    return data2d[frameValid]

def frames_with_some_valid_data(data2d):
    '''
    Return all frames with at least one column of valid data
    '''
    # data valid field of all data2d
    dv = np.array(list(map(lambda x : x.dataValid, data2d.flatten()))).reshape(data2d.shape)
    # bool array of rows with any valid data
    dv = dv.sum(axis=1).astype(bool)
    return data2d[dv]

def only_valid_data(data2d):
    '''
    Return only entries with DataValid True
    '''
    # data valid field of all data2d
    dv = np.array(list(map(lambda x : x.dataValid, data2d.flatten())))
    return data2d[dv]

def parse_file(f):
    '''
    Parse the Simulation input or output file "f".
    Returns a 2D array of LinkData.
    The first dimension is treated as the "time" axis, and the second the "link" axis.
    '''
    f = open(f, 'r')
    x = []
    lines = f.readlines()
    for line in lines:
        line = line.replace(' ', '').replace(';\n','')
        data = line.split(';')
        xi = [LinkData(string=di) for di in data]
        x.append(xi)
    return np.array(x)

def write_line(f, x):
    f.write(';'.join([str(xi) for xi in x]) + '\n')

def empty_rows(f, n):
    for i in range(n):
        x = [LinkData() for j in range(n_links_hgc_total)]
        write_line(f, x)


def check_routed(in_file, out_file):
    '''
    Check that the data in each output column is in the correct column.
    Doesn't try to check that the row (time step) matches.
    '''
    d_sim = frames_with_some_valid_data(parse_file('SimulationOutput.txt'))
    d_ref = valid_frames(algo_ref(parse_file('SimulationInput.txt')))
    return check_router_columns(d_sim, d_ref)

def check_router_columns(d_sim, d_ref):
    '''
    Check that the data in each output column is in the correct column.
    Doesn't try to check that the row (time step) matches.
    '''
    addr = np.array(list(map(lambda x : x.addr, d_ref.flatten()))).reshape(d_ref.shape)
    cols_match = np.zeros(n_inputs_pf).astype(bool)
    for i in range(n_inputs_pf):
        # Get the data from the reference with address i
        col_ref = d_ref[addr == i]
        # Get the unique indices (the data content) from the reference
        idxs_ref = set(list(map(lambda x : x.data, col_ref)))
        # Get the data from the router sim column i
        col_sim = only_valid_data(d_sim[:,i])
        # Get the unique indices (the data content) from the sim
        idxs_sim = set(list(map(lambda x : x.data, col_sim)))
        # Check the sets match
        cols_match[i] = idxs_ref == idxs_sim

    return cols_match.all()

def get_router_column(d_ref, i):
    addr = np.array(list(map(lambda x : x.addr, d_ref.flatten()))).reshape(d_ref.shape)
    return d_ref[addr == i]

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

    '''
    for i in range(4):
        x = [LinkData(dataValid=True, frameValid=True) for j in range(n_links_hgc_total)]
        for j in range(n_links_hgc_total):
            x[j].data = ii
            ii += 1
            x[j].iRegion = random.randint(0, n_regions_pf-1)
        write_line(f, x)

    empty_rows(f, 4)
    '''

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
    test_rand(f)
