import Formats

def GenerateUniformPatterFiles():
    import numpy as np
    import pandas
    nlinks = 25
    data = np.linspace(0, nlinks - 1, nlinks).astype('int')
    l = np.linspace(0, nlinks-1, nlinks).astype('int')
    d = pandas.DataFrame({'pt':data, 'eta':data, 'phi':data, 'id':data % 8, 'z0' : data, 'link':l})
    Formats.writepfile('PatternFiles/UniformEvent.txt', [d], nlinks=112, emptylinks_valid=False)
