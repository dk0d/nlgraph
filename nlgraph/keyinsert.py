import copy
import random
import textwrap
from datetime import datetime
from enum import Enum
from pathlib import Path
from typing import Dict

import numpy as np
import yaml

from .parse.nets import NetlistRegexReader, \
    Net, \
    NetType, \
    NetlistModule, \
    NetlistEntry, \
    NetlistPort


class KeyInsertException(Exception):
    pass


class PositionMethod(Enum):

    def __repr__(self):
        return self.value

    def __str__(self):
        return self.value

    random = "RN"
    sll = "SL"  # Non mutable
    logicConeSize = "CS"
    faultAnalysis = 'FA'  # Fault analysis


class KeyInsert:

    @property
    def keyString(self):
        return "".join([f'{k}' for k in self.key])

    def __init__(
        self,
        filePath: Path,
        tbSet=None,
        outDir=None,
        keyInputName='keyinput',
        keyGateName='keygate',
        keyWireName='keywire',
    ):
        self.filePath = filePath
        self.noOfTBentry = tbSet
        self.outDir = outDir

        self.keyInputName = keyInputName
        self.keyGateName = keyGateName
        self.keyWireName = keyWireName

        # Run properties
        self._insertionGates = None
        self.positionMethod = None
        self.keyTypeRatio = None
        self.key = None
        self.sampleNumber = None

    @property
    def numKeyBits(self):
        return len(self.key)

    @property
    def insertedGateLocs(self):
        locs = {}
        for m, g in self._insertionGates:
            if m not in locs.keys():
                locs[m] = [g]
            else:
                locs[m].append(g)
        return locs

    def _readNetlist(self):
        self.reader = NetlistRegexReader()
        self.reader.parseNetlist(self.filePath)
        self._sourceNumGates = sum(len(m.entries) for k, m in self.reader.modules.items())

    def run(
        self,
        nKeyBits: int,
        posMethod: PositionMethod,
        sampleNumber=None,
        keyTypeRatio: float = 1.0,
    ):

        self.keyTypeRatio = keyTypeRatio
        self.positionMethod = posMethod
        self.sampleNumber = sampleNumber

        self._readNetlist()

        if self._sourceNumGates < nKeyBits:
            raise KeyInsertException(f'Number of requested keybits ({nKeyBits})'
                                     f' higher than number of gates ({self._sourceNumGates}) in {self.filePath.stem}')

        self.key = list(np.random.binomial(1, 0.5, nKeyBits))

        topMod = self.reader.topModule
        keyNet = Net(
            self.keyInputName,
            nType=NetType.input_,
            low=0,
            high=self.numKeyBits - 1
        )
        self.reader.modules[topMod].addNet(keyNet)

        # self.reader.modules[topMod].addWire(Net(self.keyWireName, low=0, high=self.numKeyBits - 1))
        # self.reader.modules[topMod].addWire(Net(f'{self.keyWireName}NOT', low=0, high=np.sum(self.key) - 1))

        baseGates = ['XOR2X1'] * self.numKeyBits
        numInvs = [0] * self.numKeyBits

        for i, k in enumerate(self.key):
            if k == 0:
                # XOR or XNOR + NOT or XOR + NOT + NOT -- random sample one of these
                numInvs[i] = random.sample([0, 2], k=1)[0]  # either 0 or 2 inverters
            elif k == 1:
                # XNOR or XOR + NOT or XOR + NOT + NOT + NOT -- random sample one of these
                numInvs[i] = random.sample([1, 3], k=1)[0]  # either 1 or 3 inverters

        self._insertionGates = self._selectInsertionPoints(self.reader.modules)

        insertionPairs = zip(
            self._insertionGates,
            range(self.numKeyBits),
            zip(baseGates, numInvs)
        )

        self._createKeyGates(
            self.reader.modules,
            keyNet,
            insertionPairs
        )

    def save(self):
        outName = f'{self.filePath.stem}-{self.positionMethod}{self.numKeyBits}'
        outDir = self.filePath.parent / self.filePath.stem / outName if self.outDir is None else self.outDir / outName
        if self.sampleNumber is not None:
            outName = f'{outName}_s{self.sampleNumber}'
            outDir = outDir / f's{self.sampleNumber}'
        outDir.mkdir(parents=True, exist_ok=True)
        insertedPath = outDir / f'{outName}.v'
        self.writeNetlist(insertedPath)
        self.writeMeta(insertedPath.with_suffix('.yml'))
        return insertedPath

    def writeMeta(self, filePath):
        meta = dict(
            created=f'{datetime.now()}',
            key=self.keyString,
            source=str(self.filePath),
            numSourceGates=self._sourceNumGates,
            numGatesAfterInsertion=sum([len(m.entries) for k, m in self.reader.modules.items()]),
            moduleNames=list(self.reader.modules.keys()),
            xorRatio=self.keyTypeRatio,
            muxRatio=1 - self.keyTypeRatio,
            positionMethod=self.positionMethod.value,
            insertionLocations=self.insertedGateLocs
        )
        with filePath.open('w+') as fp:
            yaml.dump(meta, fp)

    def _selectInsertionPoints(self, modules: [NetlistModule]):
        entries = [(name, e) for name, m in modules.items() for e in m.entries.keys()]
        if self.positionMethod == PositionMethod.random:
            insertionGates = random.sample(entries, self.numKeyBits)
            return insertionGates
        elif self.positionMethod == PositionMethod.sll:
            raise NotImplementedError  # nonMutableSelector() from java
        elif self.positionMethod == PositionMethod.logicConeSize:
            raise NotImplementedError  # fanBasedSelector() from java
        else:
            raise KeyInsertException("Unsupported Position Method")

    def _createKeyGates(self, modules: Dict[str, NetlistModule], keyNet: Net, insertionPairs):

        nXor = np.round(self.keyTypeRatio * self.numKeyBits)
        nMux = self.numKeyBits - nXor

        if nMux > 0:
            # TODO: Find gate-node pairs for mux insertion
            # TODO: Consider Combination Loops
            raise NotImplementedError

        for (module, gate), keyIdx, (baseGate, numNots) in insertionPairs:
            module = modules[module]
            self._insertXor(
                gate=gate,
                module=module,
                baseModuleName=baseGate,
                keyNet=keyNet,
                keyBitIdx=keyIdx,
                numInvs=numNots
            )

    def _insertXor(
        self,
        gate: str,
        module: NetlistModule,
        keyBitIdx,
        keyNet,
        baseModuleName='XOR2X1',
        invModuleName='INVX1',
        numInvs=0,
    ):
        entry = module.entries[gate]
        inSeq = module.library.numPinsIn(2)
        reversePorts = inSeq[0] is None
        # baseOutPin = module.library.modules[baseModuleName]['outputs'][0]
        # invOutPin = module.library.modules[invModuleName]['outputs'][0]
        _keyNet = Net(f'{self.keyWireName}_{keyBitIdx}', nType=NetType.wire)
        ports = [
            NetlistPort(inSeq[0], _keyNet),
            NetlistPort(inSeq[1], Net(f'{self.keyInputName}[{keyBitIdx}]',
                                      nType=NetType.input_, low=keyNet.low,
                                      high=keyNet.high)),
            copy.deepcopy(entry.outPort),
        ]
        if reversePorts:
            ports.reverse()

        baseEntry = NetlistEntry(
            baseModuleName,
            f'{self.keyGateName}_{keyBitIdx}',
            ports
        )

        connectPort = copy.deepcopy(entry.outPort)
        entry.outPort.net = _keyNet
        newEntries = [baseEntry]
        lastEntry = baseEntry

        for i in range(numInvs):
            n = Net(f'{self.keyWireName}NOT_{keyBitIdx}_{i}', nType=NetType.wire)
            lastEntry.outPort.net = n
            _ports = [
                NetlistPort(inSeq[0], Net(f'{self.keyWireName}NOT_{keyBitIdx}_{i}', nType=NetType.wire)),
                copy.deepcopy(connectPort)
            ]
            if reversePorts:
                _ports.reverse()
            lastEntry = NetlistEntry(
                invModuleName,
                f'{self.keyGateName}NOT_{keyBitIdx}_{i}',
                _ports
            )
            newEntries.append(lastEntry)

        module.addEntries(newEntries)

    def writeNetlist(
        self,
        outPath: Path
    ):
        outText = f"// Key Inserted Benchmark {self.filePath.stem} created by keyinserter.py\n" \
                  f"// Created on: {datetime.now()}\n\n"
        tr = textwrap.TextWrapper(width=60, subsequent_indent='  ')
        for m, mod in self.reader.modules.items():
            inputList = ', '.join(list(mod.inputs.keys()) + list(mod.outputs.keys()))
            modDec = f'module {m} ({inputList});\n\n'
            outText += "\n".join(tr.wrap(modDec))
            outText += "\n\n"
            buses = [
                        ('input', n) for k, n in mod.inputs.items() if n.isBus
                    ] + [
                        ('output', n) for k, n in mod.outputs.items() if n.isBus
                    ] + [
                        ('wire', n) for k, n in mod.wires.items() if n.isBus
                    ]
            for prefix, b in buses:
                outText += f'{b.busDec(prefix)}\n'
            outText += "\n\n"

            inputDec = 'input ' + ", ".join([f'{n}' for k, n in mod.inputs.items() if not n.isBus]) + ';'
            outText += "\n".join(tr.wrap(inputDec))
            outText += "\n\n"

            outputDec = 'output ' + ", ".join([f'{n}' for k, n in mod.outputs.items() if not n.isBus]) + ';'
            outText += "\n".join(tr.wrap(outputDec))
            outText += "\n\n"

            wireDec = 'wire ' + ", ".join([f'{n}' for k, n in mod.wires.items() if not n.isBus]) + ';'
            outText += "\n".join(tr.wrap(wireDec))
            outText += "\n\n"

            for e, entry in mod.entries.items():
                outText += f"{entry};\n"

            outText += "endmodule\n"

        outPath.write_text(outText)
