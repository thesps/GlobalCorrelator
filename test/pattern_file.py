import numpy as np
import bitstring as bs

def header(nlinks):
  txt = 'Board Demo\n'
  txt += ' Quad/Chan : '
  for i in range(nlinks):
    quadstr = '       q{:02d}c{}       '.format(i//4, i%4)
    txt += quadstr
  txt += '\n      Link : '
  for i in range(nlinks):
    txt += '        {:03d}        '.format(i)
  txt += '\n'
  return txt

def two_links_data(iframe, random=False):
    '''
    Generate one frame of data, returned in string format for this two link integer test.
    Args:
        iframe : integer : the index of the frame for the line header
        random : boolean : when False, 0v00... data is written; when True, random 16b integer data is written
    Returns:
        Tuple:
            [0] : the frame string (e.g. Frame 0007 : 1v0000000000001234 1v0000000000005678)
            [1] : the sum of the random values written in the frame
    '''
    txt = 'Frame {:04d} :'.format(iframe)
    x = np.random.randint(-2**15, 2**15-1, size=2) if random else np.zeros(2, dtype=np.int)
    v = '1' if random else '0'
    for xi in x:
        txt += ' ' + v + 'v' + bs.pack('uint:48, int:16', 0, xi).hex
    txt += ' \n'
    if random:
        print(x, x.sum())
    return txt, x.sum()

def add_test_random(fname, n):
    '''
    Write n frames of random 16 bit integers onto links 0 and 1 into file fname
    Write the reference sums to another file (name fname + '.ref')
    '''
    f = open(fname, 'w')
    f.write(header(2))
    iframe = 0
    sums = []
    # Write 6 frames of null data
    for i in range(6):
        line, x = two_links_data(iframe, False)
        f.write(line)
        sums.append(x)
        iframe += 1
    # Write n frames of random integers
    for i in range(n):
        line, x = two_links_data(iframe, True) 
        f.write(line)
        sums.append(x)
        iframe += 1
    # Pad the file up to 1024 frames long
    for i in range(1024-6-n):
        f.write(two_links_data(iframe, False)[0])
        iframe += 1
    f.close()

    # Write out the reference (the sums in hex form)
    fref = open(fname + '.ref', 'w')
    for sumi in sums:
        fref.write(bs.pack('uint:3, int:17', 0, sumi).hex + '\n')

if __name__ == '__main__':
    add_test_random('source.txt', 10)
