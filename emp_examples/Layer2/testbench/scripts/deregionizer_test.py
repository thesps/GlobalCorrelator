import numpy as np
import random

config_6x16 = {'regions' : (6, 6),
               'particles_per_region' : 16,
               'particles_per_event' : 128,
               'mu' : 4,
               'sigma' : 2}

def random_pattern_file(filehandle, region_config):
    c = region_config
    # print header
    filehandle.write('Board TEST')
    line = 'Quad/Chan :            '
    for i in range(c['regions'][1] * c['particles_per_region']):
        line += 'q' + '%02d' % int(i // 4) + 'c' + str(i % 4)
        line += '            '
    line += '\n'
    filehandle.write(line)
    line = 'Link :            '
    for i in range(c['regions'][1] * c['particles_per_region']):
        line += '%03d' % i
        line += '            '
    line += '\n'
    filehandle.write(line)

    iFrame = 0
    for i in range(6):
        line = 'Frame {} : '.format('%04d' % iFrame)
        for i in range(c['regions'][1] * c['particles_per_region']):
            line += '0v0000000000000000 '
        line += '\n'
        filehandle.write(line)
        iFrame += 1

    for i in range(c['regions'][0]):
        line = 'Frame {} : '.format('%04d' % iFrame)
        for j in range(c['regions'][1]):
            n = int(np.ceil(random.gauss(c['mu'], c['sigma'])))
            x = int(random.uniform(0, 2**16-1))
            for k in range(n):
                line += '1v800000000000' + '%04x' % x + ' '
                # The next number must be smaller
                x = int(random.uniform(0, x))
            for k in range(c['particles_per_region'] - n):
                line += '1v0000000000000000 '
        line += '\n'
        filehandle.write(line)
        iFrame += 1

    for i in range(6):
        line = 'Frame {} : '.format('%04d' % iFrame)
        for i in range(c['regions'][1] * c['particles_per_region']):
            line += '0v0000000000000000 '
        line += '\n'
        filehandle.write(line)
        iFrame += 1

    return filehandle
