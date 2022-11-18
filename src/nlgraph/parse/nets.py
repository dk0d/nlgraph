from __future__ import annotations
import re
import string
from collections import OrderedDict
from pathlib import Path
from typing import Union, List
import tqdm
from ..common import RegexConstants, LibraryType
from ..utils import NLGraphEnum, Benchmark


class Library:

    def __init__(
        self,
        name: [str, LibraryType],
        path: Path = None
    ):

        if isinstance(name, str):
            self.libType = LibraryType.get(name)
        else:
            self.libType = name

        if path is None:
            self.path = (Path(__file__).parent.parent / 'libraries' / self.libType.file).resolve()
        else:
            self.path = path

        self.pinsIn = None
        self.pinsOut = None
        self.modules = None
        if self.path is not None:
            self.parseLibrary()

    def numPinsIn(self, numIn):
        if self.libType in [LibraryType.gsc45_svt_3p0, LibraryType.gsc180_svt_3p0]:
            return list(string.ascii_uppercase[:numIn])
        elif self.libType == LibraryType.saed90_typ_1p11:
            return [f'IN{i + 1}' for i in range(numIn)]
        return [None] * numIn
        # return [f'in{i + 1}' for i in range(numIn)]

    # def _getLibType(self, module):
    #     if module in LibraryConstants.gscLibGates:
    #         return LibraryType.gsc180
    #     elif module in LibraryConstants.saedLibGates:
    #         return LibraryType.saed
    #     elif module in LibraryConstants.sharedGates:
    #         raise Exception(f'shared')
    #     return LibraryType.blackbox

    def parseLibrary(self):
        netlist = self.path.read_text()
        netlist = re.sub('\n', ' ', netlist)
        entries = re.findall(r"(module|input|output)\s+([_\w,\s\[\]]+)\s*;?|(endmodule)", netlist)
        self.pinsIn = set()
        self.pinsOut = set()
        self.modules = {}
        activeModule = None
        for e0, e1, e2 in entries:
            if e0 == 'module':
                activeModule = e1.strip(' \n()')
                self.modules[activeModule] = dict(inputs=[], outputs=[])
                # if self.libType is None:
                #     self.libType = self._getLibType(activeModule)
                # else:
                #     lt = self._getLibType(activeModule)
                #     if lt is not None and self.libType != lt:
                #         raise Exception(f'Inconsistent Library Types')
            elif e0 == 'input':
                try:
                    ports = [i.strip(' ') for i in e1.split(',')]
                    self.pinsIn.update(p for p in ports if len(p) > 0)
                    self.modules[activeModule]['inputs'].extend(ports)
                except KeyError:
                    pass
            elif e0 == 'output':
                try:
                    ports = [o.strip(' ') for o in e1.split(',')]
                    self.pinsOut.update(p for p in ports if len(p) > 0)
                    self.modules[activeModule]['outputs'].extend(ports)
                except KeyError:
                    pass
            elif e2 == 'endmodule':
                activeModule = None


class LibraryConstants:
    gscLibGates = {
        "ADDHX1", "ADDFX1", "BUFX1", "BUFX3", "DFFSRX1", "MX2X1", "OAI33X1",
        "TBUFX1", "TBUFX2", "TBUFX4", "TBUFX8", "TINVX1", "TLATSRX1", "TLATX1",
        "AND2X1", "AOI21X1", "AOI22X1", "DFFX1", "INVX1", "INVX2", "INVX4",
        "INVX8", "NAND2X1", "NAND2X2", "NAND3X1", "NAND4X1", "NOR2X1",
        "NOR3X1", "NOR4X1", "OAI21X1", "OAI22X1", "OR2X1", "OR4X1", "XOR2X1",
        "CLKBUFX1", "CLKBUFX2", "CLKBUFX3", "SDFFSRX1"
    }

    gscLibGatesForInsertion = gscLibGates.difference({
        "CLKBUFX1", "CLKBUFX2", "CLKBUFX3",
        "SDFFSRX1"
    })

    # Logical Obfuscation not performed on scan FF
    saedLibScanGates = [
        "SDFFX1", "SDFFX2", "SDFFASX1", "SDFFASX2", "SDFFARX1", "SDFFARX2", "SDFFASRX1",
        "SDFFASRX2", "SDFFASRSX1", "SDFFASRSX2", "SDFFSSRX1", "SDFFSSRX2", "SDFFNX1",
        "SDFFNX2", "SDFFNASX1", "SDFFNASX2", "SDFFNARX1", "SDFFNARX2", "SDFFNASRX1", "SDFFNASRX2"
    ]

    # Modify and insert gates
    saedLibGates = {
        "INVX0", "INVX1", "INVX2", "INVX4", "INVX8", "INVX16", "INVX32", "AND2X1", "AND2X2", "AND2X4", "AND3X1",
        "AND3X2", "AND3X4", "AND4X1", "AND4X2", "AND4X4", "NAND2X0", "NAND2X1", "NAND2X2", "NAND2X4", "NAND3X0",
        "NAND3X1",
        "NAND3X2", "NAND3X4", "NAND4X0", "NAND4X1", "OR2X1", "OR2X2", "OR2X4", "OR3X1", "OR3X2", "OR3X4", "OR4X1",
        "OR4X2", "OR4X4", "NOR2X0", "NOR2X1",
        "NOR2X2", "NOR2X4", "NOR3X0", "NOR3X1", "NOR3X2", "NOR3X4", "NOR4X0", "NOR4X1", "XOR2X1", "XOR2X2", "XOR3X1",
        "XOR3X2", "XNOR2X1", "XNOR2X2", "XNOR3X1", "XNOR3X2", "AO21X1", "AO21X2", "AO22X1", "AO22X2", "AO221X1",
        "AO221X2", "AO222X1", "AO222X2", "AOI21X1",
        "AOI21X2", "AOI22X1", "AOI22X2", "AOI221X1", "AOI221X2", "AOI222X1", "AOI222X2", "OA21X1", "OA21X2", "OA22X1",
        "OA22X2", "OA221X1", "OA221X2", "OA222X1",
        "OA222X2", "OAI21X1", "OAI21X2", "OAI22X1", "OAI22X2", "OAI221X1", "OAI221X2", "OAI222X1", "OAI222X2",
        "MUX21X1",
        "MUX21X2", "MUX41X1", "MUX41X2", "HADDX1", "HADDX2", "FADDX1", "FADDX2", "DEC24X1", "DEC24X2", "DFFX1", "DFFX2",
        "DFFASX1", "DFFASX2", "DFFARX1",
        "DFFARX2", "DFFASRX1", "DFFASRX2", "DFFSSRX1", "DFFSSRX2", "DFFNX1", "DFFNX2", "DFFNASX1", "DFFNASX2",
        "DFFNARX1", "DFFNARX2", "DFFNASRX1", "DFFNASRX2",
        "DFFNASRQX1", "DFFNASRQX2", "DFFNASRNX1", "DFFNASRNX2", "LNANDX1", "LNANDX2", "LATCHX1", "LATCHX2", "LASX1",
        "LASX2", "LARX1", "LARX2", "LASRX1", "LASRX2", "LASRQX1", "LASRQX2", "LASRNX1",
        "LASRNX2",
        "CGLPPSX2",  # Clock modifier
        "CGLPPSX4", "CGLPPSX8", "CGLPPSX16", "CGLNPSX2", "CGLNPSX4", "CGLNPSX8", "CGLNPSX16", "CGLPPRX2", "CGLPPRX8",
        "CGLNPRX2", "CGLNPRX8", "DELLN1X2", "DELLN2X2", "DELLN3X2", "PGX1", "PGX2", "PGX4", "BSLEX1", "BSLEX2",
        "BSLEX4", "ISOLANDX1", "ISOLANDX2", "ISOLANDX4",
        "ISOLANDX8", "ISOLORX1", "ISOLORX2", "ISOLORX4", "ISOLORX8", "LSUPX1", "LSUPX2", "LSUPX4",
        "LSUPX8", "LSDNX1", "LSDNX2", "LSDNX4", "LSDNX8", "LSUPENX1", "LSUPENX2", "LSUPENX4", "LSUPENX8", "LSDNENX1",
        "LSDNENX2", "LSDNENX4", "LSDNENX8", "RDFFX1", "RDFFX2", "RSDFFX1", "RSDFFX2", "RDFFNX1", "RDFFNX2", "RSDFFNX1",
        "RSDFFNX2", "HEADX2", "HEADX4",
        "HEADX8", "HEADX16", "HEADX32", "AOINVX1", "AOINVX2", "AOINVX4", "AOBUFX1", "AOBUFX2", "AOBUFX4", "AODFFARX1",
        "AODFFARX2",
        "AODFFNARX1", "AODFFNARX2", "PMT1", "PMT2", "PMT3", "NMT1", "NMT2", "NMT3",
        "TIEH",  # SPECIAL CASE
        "TIEL"  # SPECIAL CASE
        "BUSKP", "ANTENNA", "DCAP", "CLOAD1", "SHFILL2", "DHFILLHLH2", "DHFILLLHL2", "DHFILLHLHLS11",
    }

    # saedLibGatesForInsertion = saedLibGates.difference({
    #     "BUSKP", "ANTENNA", "DCAP", "CLOAD1", "SHFILL2", "DHFILLHLH2", "DHFILLLHL2", "DHFILLHLHLS11"
    # })

    sharedGates = [
        "AND2X1", "AOI21X1", "AOI22X1", "DFFX1", "INVX1", "INVX2", "INVX4", "INVX8", "NAND2X1",
        "NAND2X2", "NAND3X1", "NAND4X1", "NOR2X1", "NOR3X1", "NOR4X1", "OAI21X1", "OAI22X1",
        "OR2X1", "OR4X1", "XOR2X1"
    ]


class GateType(str, NLGraphEnum):
    and_ = ('and', r'[^n]and|^and')
    nor = ('nor', r'nor')
    inv = ('inv', r'inv|hi\ds\d|^i\ds\d')
    nand = ('nand', r'nand|nnd\d')
    or_ = ('or', r'[^xn]or|^or')
    xor = ('xor', r'xor')
    buffer = ('buffer', r'buf|nb\d|^hnb\d')

    input = ('input', r'in(put)?|__PI__')
    output = ('output', r'out(put)?|__PO__')

    xnor = ('xnor', r'xnor|xnr')
    ff = ('dff', r'[^s]dff|^ff|^dff')
    scanff = ('sdff', r'sdff|sff')
    bufferInv = ('bufferinv', r'^hib\ds\d|^ib\d\w\d')
    or_and = ('or_and', r'oa')
    and_or = ('and_or', r'ao')
    mux = ('mux', r'mux')
    latch = ('latch',)

    bias0 = ('bias0', r"1'b0")
    bias1 = ('bias1', r"1'b1")
    adder = ('adder', r'add')

    def __lt__(self, other):
        if hasattr(GateType, 'input') and hasattr(GateType, 'output'):
            if self == GateType.input or other == GateType.output:
                return True
            elif other == GateType.input or self == GateType.output:
                return False
        return self.value < other.value

    def __le__(self, other):
        if hasattr(GateType, 'input') and hasattr(GateType, 'output'):
            if self == GateType.input or other == GateType.output:
                return True
            elif other == GateType.input or self == GateType.output:
                return False
        return self.value <= other.value

    def __gt__(self, other):
        if hasattr(GateType, 'output'):
            if self == GateType.output:
                return True
            elif other == GateType.output:
                return False
        return self.value > other.value

    def __ge__(self, other):
        if hasattr(GateType, 'output'):
            if self == GateType.output:
                return True
            elif other == GateType.output:
                return False
        return self.value >= other.value


class NetType(str, NLGraphEnum):
    input_ = 'input'
    output_ = 'output'
    wire = 'wire'


class NetlistPort:

    def __repr__(self):
        if self.pin is not None:
            return f'.{self.pin}({self.net})'
        return f'{self.net}'

    def __str__(self):
        return self.__repr__()

    def __eq__(self, other):
        return \
            self.pin == other.pin and \
            self.net == other.net

    def direction(
        self,
        regexFlavor='pin'
    ):
        if regexFlavor == 'pin':
            inputRegex, outputRegex = (
                RegexConstants.PIN_INPUT_EXP,
                RegexConstants.PIN_OUTPUT_EXP
            )
        else:
            inputRegex, outputRegex = (
                RegexConstants.ADDER_INPUT_EXP,
                RegexConstants.ADDER_OUTPUT_EXP
            )
        if self.pin is not None:
            if re.search(inputRegex, self.pin) is not None:
                return 'input'
            return 'output'
        return None

    def __init__(self, pin, net):
        self.pin = pin
        self.net: Net = net


class Net:

    def __repr__(self):
        if self.isBus:
            return self.busIdxString()
        return self.name

    def __str__(self):
        return self.__repr__()

    def __eq__(self, other: Net):
        return self.name == other.name and \
               self.low == other.low and \
               self.high == other.high and \
               self.netType == other.netType

    @property
    def isBus(self):
        return self._busIdx is not None or (self.low is not None and self.high is not None)

    def busDec(self, prefix='wire'):
        return f'{prefix} [{self.low}:{self.high}] {self.name};'

    @property
    def busIdx(self):
        return self._busIdx

    def busIdxString(self, idx=None):
        if idx is not None:
            return f'{self.name}[{idx}]'
        elif self._busIdx is not None:
            return f'{self.name}[{self._busIdx}]'
        elif self._busIdx is None and (self.low is not None and self.high is not None):
            return f'{self.name}[{self.low}:{self.high}]'
        return self.name

    def __init__(
        self,
        n,
        nType: NetType,
        low=None,
        high=None,
        leavingFrom=None,
        goingTo=None,
    ):
        if leavingFrom is None:
            leavingFrom = set()
        if goingTo is None:
            goingTo = set()
        self.netType = nType
        if '[' in n or ']' in n:
            self.name, idx = re.search("(" + RegexConstants.ID_EXP + ")\[(\d+)\]", n).groups()
            self._busIdx = int(idx)
        else:
            self._busIdx = None
            self.name = n
        self.low = int(low) if low is not None else low
        self.high = int(high) if high is not None else high
        self.leavingFrom = leavingFrom
        self.goingTo = goingTo
        self.aliases = set()

    def addAlias(self, aliasIdentifier):
        self.aliases.add(aliasIdentifier)

    def addAliases(self, aliasIds: list):
        self.aliases.update(aliasIds)


class NetlistEntry:

    def __repr__(self):
        return f'{self.module} {self.moduleId} {self.portsListString()}'

    @property
    def nPorts(self):
        return len(self.ports)

    @property
    def outPort(self):
        for p in self.ports:
            if p.direction() == 'output':
                return p
        # assume first port is output if direction is undefined
        return self.ports[0]

    def portsListString(self):
        out = '('
        out += " ".join(f'{port},' for port in self.ports)
        out = out[:-1]  # remove trailing comma
        out += ')'
        return out

    def __init__(self, module, moduleId, ports: Union[List[NetlistPort], str]):
        self.module = module
        self.moduleId = moduleId
        self.gateType = None
        if isinstance(ports, str):
            self.ports = []
            _ps = [p.strip(' ') for p in ports.split(',')]
            if '.' in ports:
                for portDec in _ps:
                    matches = re.search(RegexConstants.PORT_DECLARATION_EXP, portDec)
                    pin, net = matches.groups()
                    pin = pin.strip(' ')
                    net = Net(net.strip(' '), nType=NetType.wire)  # defaults wire
                    self.ports.append(NetlistPort(pin, net))
            else:
                nNets = len(_ps)
                for i, port in enumerate(_ps):
                    net = Net(port, nType=NetType.wire)
                    self.ports.append(NetlistPort(None, net))
        else:
            self.ports = ports


class NetlistModule:

    def __init__(self, text: str = None, verbose=False, library=None):
        self.name = None
        self.inputs = OrderedDict()
        self.outputs = OrderedDict()
        self.wires = OrderedDict()
        self.entries = OrderedDict()
        self.assignments = OrderedDict()
        self.library = library
        if text is not None:
            self.setModule(text, verbose)

    def setModule(self, netlist: str, verbose=False):
        netlist = re.sub('\n', ' ', netlist)
        name, _ = re.search(RegexConstants.MODULE_EXP, netlist).groups()
        self.name = name

        inputs = re.findall(RegexConstants.INPUT_EXP, netlist)
        assigns = re.findall(RegexConstants.ASSIGN_EXP, netlist)
        outputs = re.findall(RegexConstants.OUTPUT_EXP, netlist)
        entries = re.findall(RegexConstants.ENTRY_EXP, netlist)
        wires = re.findall(RegexConstants.WIRE_EXP, netlist)

        self.inputs.update(self.processInOutWire(inputs, nType=NetType.input_))
        self.outputs.update(self.processInOutWire(outputs, nType=NetType.output_))
        self.wires.update(self.processInOutWire(wires, NetType.wire))

        for assignment in assigns:
            self.addAssignment(assignment)

        if verbose:
            entries = tqdm.tqdm(entries, desc=f'Reading {self.name}')

        for entry in entries:
            moduleName, identifier, portlist = entry
            if 'module' == moduleName:
                continue

            entry = NetlistEntry(moduleName, identifier, portlist)

            for i, port in enumerate(entry.ports):
                rd = None
                if port.net.name in self.inputs:
                    port.net.netType = NetType.input_
                    rd = self.inputs
                elif port.net.name in self.outputs:
                    port.net.netType = NetType.output_
                    rd = self.outputs
                elif port.net.name in self.wires:
                    port.net.netType = NetType.wire
                    rd = self.wires

                if port.net.isBus:
                    port.net.low = rd[port.net.name].low
                    port.net.high = rd[port.net.name].high

                direction = port.direction('adder' if False else 'pin')
                if direction is None:
                    # assume first port is output
                    direction = 'input' if i > 0 else 'output'

                if port.net.name == "1'b0" or port.net.name == "1'b1":
                    raise NotImplementedError
                elif direction == 'input':
                    rd[port.net.name].goingTo.add((entry.moduleId, port.pin))
                elif direction == 'output':
                    rd[port.net.name].leavingFrom.add((entry.moduleId, port.pin))
                    if len(rd[port.net.name].leavingFrom) > 1:
                        raise Exception(f'Defining more than 1 output for net {port.net}')

            if self.library is None:
                self.library = Library(name=entry.module)
            self.entries[entry.moduleId] = entry

    def addNet(self, net: Net):
        if net.netType == NetType.input_:
            nd = self.inputs
        elif net.netType == NetType.output_:
            nd = self.outputs
        elif net.netType == NetType.wire:
            nd = self.wires
        else:
            raise Exception(f'Unsupported NetType {net.netType} for net {net}')

        if net.name not in nd:
            nd.update({net.name: net})

    def addEntry(self, entry: NetlistEntry):
        if entry.moduleId in self.entries:
            raise Exception(f'Entry already present in module')
        for port in entry.ports:
            self.addNet(port.net)
        self.entries.update({entry.moduleId: entry})

    def addEntries(self, entries: [NetlistEntry]):
        for entry in entries:
            self.addEntry(entry)

    def popEntry(self, entryId: str):
        entry = self.entries.pop(entryId)
        # for port in entry.ports:
        #     if port.net.netType == NetType.input_:
        #         self.inputs.pop(port.net.name)
        #     elif port.net.netType == NetType.output_:
        #         self.outputs.pop(port.net.name)
        #     elif port.net.netType == NetType.wire:
        #         self.wires.pop(port.net.name)
        return entry

    def processInOutWire(self, inputs, nType: NetType):
        ins = {}
        for i in inputs:
            bits, _nets = i
            if len(bits) > 0:
                r = [int(b.strip('\n ')) for b in bits.split(':')]
                r.sort()
                nLow, nHigh = r
            else:
                nLow, nHigh = None, None

            if ',' in _nets and nHigh is None:
                _nets = {m.strip('\n '): Net(m.strip('\n '), nType=nType) for m in _nets.split(',')}
            elif nHigh is not None and nLow is not None:
                _nets = {_nets: Net(_nets, nType=nType, low=nLow, high=nHigh)}
            else:
                _nets = {_nets: Net(_nets, nType=nType)}
            ins.update(_nets)
        return ins

    def addAssignment(self, assignment: Union[str, tuple]):

        if isinstance(assignment, str):
            assignedTo, identifier = assignment.split('=')
        else:
            assignedTo, identifier = assignment

        self.assignments[assignedTo] = identifier

        aliases = [assignedTo]
        while identifier in self.assignments:
            aliases.append(identifier)
            identifier = self.assignments[identifier]

        nets = None
        if identifier in self.inputs:
            nets = self.inputs
        elif identifier in self.outputs:
            nets = self.outputs
        elif identifier in self.wires:
            nets = self.wires
        else:
            raise Exception(f'Identifier not found: {identifier}')

        nets[identifier].addAliases(aliases)


class NetlistRegexReader:

    def __init__(self):
        self.modules = {}
        self.topModule = None
        self.benchmark = None

    def parseNetlist(self, filePath: Path, verbose: bool = False):
        netlist = filePath.read_text()
        modules = re.split(r'\s*endmodule\s*', netlist)
        modules = [m for m in modules if len(m) > 0]
        self.benchmark = Benchmark.fromDesignPath(filePath)
        for m in modules:
            mod = NetlistModule(m, library=Library(self.benchmark.libraryType))
            if self.topModule is None:
                self.topModule = mod.name
            self.modules[mod.name] = mod
