import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrow, Rectangle
import pandas
import numpy as np

h, w = 0.8, 0.8
offs = 4
colors = ['#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#ffff33','#a65628','#f781bf','#999999']

def frame(tick, RouterD, RouterInt, RouterQ, BufferQ, Buffer):
    
    f = plt.figure()
    ax = f.add_subplot(1,1,1)

    # Draw the index setter
    #rect = Rectangle((0.2+offs, 12), width=4./3 * 18 + 0.1, height=1, edgecolor='black', facecolor='gray', linewidth=1)
    #ax.text(0.2+offs + (4./3 * 18 + 0.1)/2, 12.5, "Index Assignment", horizontalalignment='center', verticalalignment='center')

    ax.text(0, 12, 'Tick : %03d' % tick)
    # Draw the arrows inputs -> routers
    for i in range(18):
        j, k = i // 3, i % 3
        x0 = 4. / 3 * i+0.1 + w / 2 + offs
        x1 = 4*j+0.2 + k * 3.4 / 3 + 3.4 / 6 + offs
        y0, y1 = 10, 8+h
        arr = FancyArrow(x0, y0, x1-x0, y1-y0, head_length=0, head_width=0)
        ax.add_patch(arr)

    # Draw the arrows routers -> intermediate array
    for i in range(24):
        j, k = i // 4, i % 4
        x0 = 4*j+0.2 + k * 3.4 / 4 + 3.4 / 8 + offs
        x1 = i + w / 2 + offs
        y0, y1 = 8, 7.8
        arr = FancyArrow(x0, y0, x1-x0, y1-y0)
        ax.add_patch(arr)

    # Draw the input boxes
    for i in range(18):
        j, k = i // 3, i % 3
        fc='white'
        d = RouterD[RouterD.Index == i]
        if len(d) > 0:
            fc = colors[int(d.iRegion) % len(colors)]
        rect = Rectangle((4. / 3 * i+0.1 + offs, 10), width=w, height=h, edgecolor='black', facecolor=fc, linewidth=1)
        if len(d) > 0:
            ax.text(4. / 3 * i+0.1+w/2+offs, 10+h/2, str(int(d.addr)), horizontalalignment='center', verticalalignment='center')
        ax.add_patch(rect)

    # Draw the routers
    for i in range(6):
        rect = Rectangle((4*i+0.2 + offs, 8), width=3.4, height=h, edgecolor='black', facecolor='gray', linewidth=1)
        ax.text(4*i+0.2 + offs + 3.4/2, 8+h/2, "Router", horizontalalignment='center', verticalalignment='center')
        ax.add_patch(rect)

    # Draw the arrows intermediate array -> second router layer
    # Connect y(j)(i) <= x(i)(j)
    for i in range(6):
        for j in range(4):
            x0 = 4 * i + j + w / 2 + offs
            x1 = 8*j + 0.2 + i * 7.4 / 6 + 7.4 / 12
            y0, y1 = 7, 4.8
            alpha = 1 if len(RouterInt[RouterInt.Index == i]) > 0 else 0.25
            arr = FancyArrow(x0, y0, x1-x0, y1-y0, alpha=alpha)
            ax.add_patch(arr)

    # Draw the intermediate boxes
    for i in range(24):
        fc = 'white'
        d = RouterInt[RouterInt.Index == i]
        if len(d) > 0:
            fc = colors[int(d.iRegion) % len(colors)]
        rect = Rectangle((i+offs, 7), width=w, height=h, edgecolor='black', facecolor=fc, linewidth=1)
        if len(d) > 0:
            ax.text(i+offs+w/2, 7+h/2, str(int(d.addr)), horizontalalignment='center', verticalalignment='center')
        ax.add_patch(rect)

    # Arrows joining second router stage -> output
    for i in range(32):
        j, k = i % 4, i // 4
        x0 = 8 * j + 0.2 + k * 7.4 / 8 + 7.4 / 16
        x1 = 4 * k + j + w / 2
        y0, y1 = 4, 0.8
        alpha = 1 if len(RouterQ[RouterQ.Index == i]) > 0 else 0.25
        alpha = alpha if i < 24 else 0.25
        arr = FancyArrow(x0, y0, x1-x0, y1-y0, alpha=alpha)
        ax.add_patch(arr)

    # Draw the routers
    for i in range(4):
        rect = Rectangle((8*i+0.2, 4), width=7.4, height=h, edgecolor='black', facecolor='gray', linewidth=1)
        ax.text(8*i+0.2 + 7.4 / 2, 4+h/2, 'Router', horizontalalignment='center', verticalalignment='center')
        ax.add_patch(rect)

    # Draw the arrows from output boxes to region buffers
    # and region buffers to outputs
    for i in range(32):
        c = 'black' if i < 24 else 'gray'
        x = i+w/2
        y0 = 0+h/2
        y1 = -h
        arr = FancyArrow(x, y0, 0, y1-y0, color=c)
        ax.add_patch(arr)
        arr = FancyArrow(x, -10*h, 0, -1.5, color=c)
        ax.add_patch(arr)

    # Draw the output boxes
    for i in range(32):
        fc = 'white'
        d = RouterQ[RouterQ.Index == i]
        if len(d) > 0:
            fc = colors[int(d.iRegion) % len(colors)]
        ec = 'black' if i < 24 else 'gray'
        rect = Rectangle((i, 0), width=w, height=h, edgecolor=ec, facecolor=fc, linewidth=1)
        if len(d) > 0:
            ax.text(i+w/2, 0+h/2, str(int(d.addr)), horizontalalignment='center', verticalalignment='center')
        ax.add_patch(rect)

    # Draw the region buffers
    for i in range(32):
        for j in range(9):
            fc = 'white'
            if Buffer[i][j]:
                fc = colors[j]
            ec = 'black' if i < 24 else 'gray'
            rect = Rectangle((i, (-10+j) * h), width=w, height=h, edgecolor=ec, facecolor=fc, linewidth=1)
            if Buffer[i][j]:
                ax.text(i+w/2, (-10+j)*h+h/2, str(i), verticalalignment='center', horizontalalignment='center')
            ax.add_patch(rect)

    # Update the buffer
    for i in range(32):
        d = RouterQ[RouterQ.Index == i]
        if len(d) > 0:
            Buffer[i][int(d.iRegion)] = True

    # Draw the output boxes
    for i in range(32):
        fc = 'white'
        d = BufferQ[BufferQ.Index == i]
        if len(d) > 0:
            fc = colors[int(d.iRegion) % len(colors)]
        ec = 'black' if i < 24 else 'gray'
        rect = Rectangle((i, -10), width=w, height=h, edgecolor=ec, facecolor=fc, linewidth=1)
        if len(d) > 0:
            ax.text(i+w/2, -10+h/2, str(int(d.addr)), horizontalalignment='center', verticalalignment='center')
        ax.add_patch(rect)

    ax.set_xlim((0, 32))
    ax.set_ylim((-13, 13))
    ax.set_aspect('equal')
    ax.axis('off')
    plt.tight_layout()
    return f

if __name__ == "__main__":
    RouterD = pandas.read_csv('testfiles/RouterD.txt', header=1, delim_whitespace=True)
    RouterInt = pandas.read_csv('testfiles/RouterInt.txt', header=1, delim_whitespace=True)
    RouterQ = pandas.read_csv('testfiles/RouterQ.txt', header=1, delim_whitespace=True)
    BufferQ = pandas.read_csv('testfiles/BufferQ.txt', header=1, delim_whitespace=True)
    Buffer = np.zeros((32, 9), dtype=bool)
    iFrame = 0
    for i in range(max(BufferQ.Clock) + 1):
        a = RouterD[RouterD.Clock == i]
        b = RouterInt[RouterInt.Clock == i]
        c = RouterQ[RouterQ.Clock == i]
        d = BufferQ[BufferQ.Clock == i]
        f = frame(iFrame, a, b, c, d, Buffer)
        f.savefig('animation/%03d.png' % iFrame)
        iFrame += 1
    #for i in range(5):
    #    a = RouterD[RouterD.Clock == 4]
    #    b = RouterInt[RouterInt.Clock == 4]
    #    c = RouterQ[RouterQ.Clock == 4]
    #    f = frame(iFrame, a, b, c, Buffer)
    #    f.savefig('animation/%03d.png' % iFrame)
    #    iFrame += 1

