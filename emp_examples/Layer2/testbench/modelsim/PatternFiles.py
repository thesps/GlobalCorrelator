import Formats

def GenerateUniformPatterFiles():
    import numpy as np
    import pandas
    nlinks = 25
    nframes = 1
    data = np.linspace(0, nframes * nlinks - 1, nframes * nlinks).astype('int')
    l = np.linspace(0, nframes * nlinks - 1, nframes * nlinks).astype('int') % nlinks
    d = pandas.DataFrame({'pt':data, 'eta':data, 'phi':data, 'id':data % 8, 'z0' : data, 'link':l})
    Formats.writepfile('PatternFiles/UniformEvent.txt', [d], nlinks=112, emptylinks_valid=False)

def GeneratePatternFileOneRegionHighestPtLeft():
    import numpy as np
    import pandas
    nlinks = 25
    nframes = 1
    data = np.linspace(0, nframes * nlinks - 1, nframes * nlinks).astype('int')
    data = np.flip(data)
    l = np.linspace(0, nframes * nlinks - 1, nframes * nlinks).astype('int') % nlinks
    d = pandas.DataFrame({'pt':data, 'eta':data, 'phi':data, 'id':data % 8, 'z0' : data, 'link':l})
    Formats.writepfile('PatternFiles/UniformEvent.txt', [d], nlinks=112, emptylinks_valid=False)

