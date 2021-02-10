import uproot
import numpy as np
import bitstring
import pandas
import matplotlib.pyplot as plt
import matplotlib.colors as colors
import os
from shutil import copyfile

class Regions:
    '''A simplistic region maker (not realistic)'''
    def __init__(self, eta_max, n_eta, n_phi):
        self.phi = np.linspace(-np.pi, np.pi, n_phi)
        self.eta = np.linspace(-eta_max, eta_max, n_eta)
        
    def iRegion(self, cand, debug=False):
        '''Get the (iEta, iPhi) of the candidate'''
        wherePhi = np.argwhere((cand.phi >= self.phi) & (cand.phi < np.roll(self.phi, -1)))
        whereEta = np.argwhere((cand.eta >= self.eta) & (cand.eta < np.roll(self.eta, -1)))
        if len(wherePhi)>0 and len(whereEta)>0:
            iPhi = wherePhi[0][0]
            iEta = whereEta[0][0]
            return (iEta, iPhi) 
        else:
            if debug:
                print("Candidate " + str(cand) + " has no region")
            return False
    
    def regionize(self, event_candidates, sort=True, truncate=False):
        '''Get the particles within the regions'''
        region_candidates = [[[] for i in range(len(self.phi))] for j in range(len(self.eta))]
        for candidate in event_candidates:
            iR = self.iRegion(candidate)
            if iR:
                iEta, iPhi = iR[0], iR[1]
                region_candidates[iEta][iPhi].append(candidate)
        if sort:
            for iEta, regions_eta in enumerate(region_candidates):
                for iPhi, region in enumerate(regions_eta):
                    cands = sorted(region, key=PuppiCand.pt, reverse=True)
                    cands = cands if not truncate else cands[:truncate]
                    region_candidates[iEta][iPhi] = cands
        return region_candidates
    
    def fiducial(self, event_candidates):
        '''Get the particles within the eta bounds'''
        return [cand for cand in event_candidates if abs(cand.eta) < self.eta[-1]]

class DemoRegions(Regions):
    '''An extension of the Regions class closer to the 6 board correlator demonstrator'''
    def __init__(self):
        super().__init__(5, 12, 9)
        
    def pack_event(self, pups, startframe=0, mux=False, link_map=None):
        return self.pack_event_mux(pups, startframe) if mux else \
               self.pack_event_nomux(pups, startframe, link_map)
        
    def pack_event_nomux(self, pups, startframe=0):
        '''Return frames of a PatternFile for the unregionized event pups.
        Doesn't treate the regions in a specific order, just groups them in appropriate numbers.'''
        zeropup = PuppiCand(0,0,0).toVHex(True)
        pups = np.array(self.regionize(pups, sort=True)).flatten()
        # 18 links per 6 regions (frames), 16 candidates per region
        # 20 appears because of the link_map SLR handling
        muxed_cands = [[0 for i in range(6 * 16)] for j in range(18)]
        # Loop over 'layer 1 boards' (equivalent)
        for i in range(6):
            # Loop over regions in board
            for j in range(18):
                # Loop over particles in region
                pups_r = pups[18 * i + j]
                for k in range(16):
                    if k < len(pups_r):
                        pup = pups_r[k].toVHex(True)
                    else:
                        pup = zeropup
                    muxed_cands[j][16 * i + k] = pup
        for i, f in enumerate(muxed_cands):
            yield frame(f, startframe+i, 6*16)
        
    def link_map(self):
        the_map = np.zeros(36, dtype='int')
        for i in range(0,3):
            for j in range(6):
                the_map[6*i+j] = 16 + 6*i + j
        for i in range(0,3):
            for j in range(6):
                the_map[6*(i+3)+j] = 76 + 6*i + j
        return the_map
        
    def pack_event_mux(self, pups, startframe=0, debug=False, link_map=None):
        '''Return frames of a PatternFile for the unregionized event pups.
           Doesn't treate the regions in a specific order, just groups them in appropriate numbers.
           Muxes 18 particles per region into 6 links over 3 frames'''
        zeropup = PuppiCand(0,0,0).toVHex(True)
        if debug:
            zeropup = PuppiCand(0,0,0)
        pups = np.array(self.regionize(pups, sort=True)).flatten()
        # 6 links per 6 regions (frames), 18 candidates per region
        muxed_cands = [[zeropup for i in range(6 * 6)] for j in range(18 * 3)]
        # Loop over 'layer 1 boards' (equivalent)
        for i in range(6):
            # Loop over regions in board
            for j in range(18):
                # Loop over particles in region
                pups_r = pups[18 * i + j]
                for k in range(18):
                    if k < len(pups_r):
                        pup = pups_r[k].toVHex(True)
                        if debug:
                            pup = pups_r[k] 
                    else:
                        pup = zeropup
                    muxed_cands[3 * j + k//6][6 * i + k % 6] = pup
        if debug:
            for f in muxed_cands:
                yield f
        else:
            for i, f in enumerate(muxed_cands):
                nlinks = 36 if link_map is None else 118
                yield frame(f, startframe+i, 36, link_map)
            
class Particle:
    def __init__(self, pt, eta, phi, hexdata=None):
        if hexdata is not None:
            if isinstance(hexdata, str):
                d = bitstring.pack('hex:64', hexdata)
            elif isinstance(hexdata, int):
                d = bitstring.pack('int:64', hexdata)
            pt = d[48:].uint / 4
            eta = d[38:48].int / 100
            phi = d[28:38].int / 100
        self.pt = pt
        self.eta = eta
        self.phi = phi
        
    def __str__(self):
        return "Particle({}, {}, {})".format(self.pt, self.eta, self.phi)
    
    def __repr__(self):
        return self.__str__()
    
    def __eq__(self, other):
        eq = True
        eq = eq and (self.pt == other.pt)
        eq = eq and (self.eta == other.eta)
        eq = eq and (self.phi == other.phi)
        return eq
        #if isinstance(other, self.__class__):
        #    return self.__dict__ == other.__dict__
        #else:
        #    return False
    
    def iRegion(self, regions):
        return regions.iRegion(self)
        
    def fromUproot(pt_jagged, eta_jagged, phi_jagged, ptcut=None, doround=False, pclass=None):
        if pclass is None:
            pclass = Particle
        if doround:
            eta_jagged = round(eta_jagged * 100) / 100
            phi_jagged = round(phi_jagged * 100) / 100
        events = []
        for pti, etai, phii in zip(pt_jagged, eta_jagged, phi_jagged):
            event = []
            for ptij, etaij, phiij in zip(pti, etai, phii):
                particle = pclass(ptij, etaij, phiij)
                if ptcut is None:
                    event.append(particle)
                elif particle.pt > ptcut:
                    event.append(particle)
            events.append(event)
        return events
    
    def pack(self):
        eta = np.floor(self.eta * 100)
        phi = np.floor(self.phi * 100)
        pt = np.floor(self.pt * 4)
        v = int(pt > 0)
        bs = bitstring.pack('uint:1,uint:27,int:10,int:10,uint:16',v,0,phi,eta,pt)
        return bs.hex
    
    def toVHex(self, valid):
        return str(int(valid)) + 'v' + self.pack()
    
    
class PuppiCand(Particle):
          
    def __str__(self):
        return super().__str__().replace('Particle', 'PuppiCand')
    
    def fromUproot(pt_jagged, eta_jagged, phi_jagged, ptcut=None, doround=False):
        return Particle.fromUproot(pt_jagged, eta_jagged, phi_jagged, ptcut, doround, PuppiCand)
    
    def pack_event_hr(pups, sort=False):
        #template = "   cand pt     {} eta {:04.2f} phi {:04.2f}  id 0\n"
        template = "   cand pt     {} eta {:010.8f} phi {:010.8f}  id 0\n"
        if sort:
            cands = sorted(pups, key=PuppiCand.pt, reverse=True)
        else:
            cands = pups
        for pup in cands:
            yield template.format(pup.pt, pup.eta, pup.phi)
    
    def pt(self):
        return self.pt
        
class Jet(Particle):
            
    def __str__(self):
        return super().__str__().replace('Particle', 'Jet')
    
    def fromUproot(pt_jagged, eta_jagged, phi_jagged, ptcut=None, doround=False):
        return Particle.fromUproot(pt_jagged, eta_jagged, phi_jagged, ptcut, doround, Jet)
    
    def pack_event_hr(pups):
        template = "   jet pt      {} eta {:04.2f} phi {:04.2f}  constituents 0\n"
        for pup in pups:
            yield template.format(pup.pt, pup.eta, pup.phi)
            
def write_event_hr(f, pups, jets):
    f.write("Event with {} candidates, {} jets in the selected region\n".format(len(pups), len(jets)))
    for pup in PuppiCand.pack_event_hr(pups):
        f.write(pup)
    for jet in Jet.pack_event_hr(jets):
        f.write(jet)
    f.write("\n")
    
def header(nlinks, board='JETS', link_map=None):
    txt = 'Board {}\n'.format(board)
    txt += 'Quad/Chan :'
    for i in range(nlinks):
        j = i if link_map is None else link_map[i]
        quadstr = '        q{:02d}c{}      '.format(int(j/4), int(j%4))
        txt += quadstr
    txt += '\n      Link :'
    for i in range(nlinks):
        j = i if link_map is None else link_map[i]
        txt += '         {:03d}       '.format(j)
    txt += '\n'
    return txt

def frame(vhexdata, iframe, nlinks, link_map=None):
    #assert(len(vhexdata) == nlinks), "Data length doesn't match expected number of links"
    #txt = 'Frame {:04d} :'.format(iframe)
    txt = 'Frame {:04d} :'.format(iframe)
    #if link_map is None:
    if True:
        for d in vhexdata:
            txt += ' ' + d
    else:
        for i in range(nlinks):
            if i in link_map:
                j = np.argwhere(link_map == i)[0]
                txt += ' ' + vhexdata[j]
            else:
                txt += ' 0v0000000000000000'
    txt += '\n'
    return txt

def empty_frames(n, istart, nlinks):
    ''' Make n empty frames for nlinks with starting frame number istart '''
    empty_data = '0v0000000000000000'
    empty_frame = [empty_data] * nlinks
    iframe = istart
    frames = []
    for i in range(n):
        frames.append(frame(empty_frame, iframe, nlinks))
        iframe += 1
    return frames

def pups_and_jets(d, emulator=False):
    # Extract Pups
    pups = d['l1tPFCandidates_l1pfCandidates_Puppi_RESP.']['l1tPFCandidates_l1pfCandidates_Puppi_RESP.obj']
    pt = pups['l1tPFCandidates_l1pfCandidates_Puppi_RESP.obj.m_state.p4Polar_.fCoordinates.fPt'].array()
    eta = pups['l1tPFCandidates_l1pfCandidates_Puppi_RESP.obj.m_state.p4Polar_.fCoordinates.fEta'].array()
    phi = pups['l1tPFCandidates_l1pfCandidates_Puppi_RESP.obj.m_state.p4Polar_.fCoordinates.fPhi'].array()
    pups = PuppiCand.fromUproot(pt, eta, phi, 0, doround=False)

    # Extract Jets
    algo = 'l1PFSeedConeEmulatorL1Puppi' if emulator else 'l1PFSeedConeL1Puppi'
    jets = d['l1tPFJets_{}__RESP.'.format(algo)]['l1tPFJets_{}__RESP.obj'.format(algo)]
    pt = jets['l1tPFJets_{}__RESP.obj.m_state.p4Polar_.fCoordinates.fPt'.format(algo)].array()
    eta = jets['l1tPFJets_{}__RESP.obj.m_state.p4Polar_.fCoordinates.fEta'.format(algo)].array()
    phi = jets['l1tPFJets_{}__RESP.obj.m_state.p4Polar_.fCoordinates.fPhi'.format(algo)].array()
    jets = Jet.fromUproot(pt, eta, phi, 5, doround=True)
    return (pups, jets)

def write_pattern_file(events, regions, mux=False, link_map=None):
    f = open('source.txt', 'w')
    iframe = 0
    nLinks = 36 if mux else 6*16
    f.write(header(nLinks, link_map=link_map))
    for d in empty_frames(6, iframe, nLinks):
        f.write(d)
    iframe += 6
    for pups in events:
        for d in regions.pack_event(pups, startframe=iframe, mux=mux, link_map=link_map):
            f.write(d)
            iframe += 1
        # Inter-event empty frames
        if True:
            for d in empty_frames(0, iframe, nLinks):
                f.write(d)
        #iframe += 240
    f.close()
    
def write_and_run(pups, regions, t):
    G = ""
    for i in range(10):
        G += "-G/top/payload/JetAlgo/GenJetSorts({})/Sort/Debug/FileName=Sorts{} ".format(i,i)
    write_pattern_file(pups, regions, mux=True)
    os.chdir('/home/sioni/Work/corrl2-jet-multi/proj/jet-test/')
    os.system('vsim -c -do "vsim -L extras -L Int -L IO -L Jet {} work.top; run {}us; quit -f"'.format(G, t))
    os.chdir('/home/sioni/Work/corrl2-jet-multi/src/GlobalCorrelator/emp_examples/Layer2/testbench/jet')
    
def write_and_run_cmd_vcu118(pups, regions, cfile):
    assert(len(pups) < 20), "Cannot run {} events through rx/tx buffers".format(len(pups))
    write_pattern_file(pups, regions, mux=True, link_map=True)
    os.system("empbutler -c {} do vcu118 inspect info.versions.payload".format(cfile))
    os.system("empbutler -c {} do vcu118 reset internal".format(cfile))
    os.system("empbutler -c {} do vcu118 buffers rx PlayOnce -c 16-33,76-93 --inject file://source.txt".format(cfile))
    os.system("empbutler -c {} do vcu118 buffers tx Capture -c 80-89".format(cfile))
    os.system("empbutler -c $c do vcu118 capture --rx 16-33,76-93 --tx 80-89".format(cfile))
    f = open('data/tx_summary.txt', 'r').readlines()
    jets_hw = []          
    for fi in f:
        if '1v' in fi:
            jets_ev = []
            fields = fi.split(' ')[3:]
            for field in fields:
                jet = Particle(0,0,0,hexdata=field.replace('1v',''))
                if jet.pt > 0:
                    jets_ev.append(jet)
        jets_hw.append(jets_ev)
    return jets_hw
