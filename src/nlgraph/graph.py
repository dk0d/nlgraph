from __future__ import annotations

import concurrent.futures
import itertools
import re
from collections import OrderedDict, deque
from concurrent.futures import ProcessPoolExecutor
from dataclasses import dataclass
from enum import Enum
from itertools import count
from pathlib import Path
from typing import Dict, Tuple, Optional, Set, Union, Protocol, List, Callable

import networkx as nx
import numpy as np
import pandas as pd
import torch_geometric.utils as pygeo_utils
import tqdm
from torch_geometric.data import Data

from .common import RegexConstants
from .parse.synopsis import ScoapData
from .utils import NLGraphEnum

NodeID = str
NetID = str
PortID = str


class GraphDataFactory(Protocol):
    @staticmethod
    def fromData(data: Data):
        raise NotImplementedError


@dataclass(frozen=True, eq=True)
class NodePort:
    nodeId: NodeID
    port: PortID

    def __repr__(self):
        return f"{self.nodeId}/{self.port}"

    def __str__(self):
        return self.__repr__()


class NodeType(str, NLGraphEnum):
    """
    Comment or uncomment to enable support for more node types.

    """

    and_ = ("and", r"[^n]and|^and")
    nor = ("nor", r"nor")
    inv = ("inv", r"inv|hi\ds\d|^i\ds\d")
    nand = ("nand", r"nand|nnd\d")
    or_ = ("or", r"[^xn]or|^or")
    xor = ("xor", r"xor")

    input = ("input", r"in(put)?|__PI__")
    output = ("output", r"out(put)?|__PO__")
    buffer = ("buffer", r"buf|nb\d|^hnb\d")

    xnor = ("xnor", r"xnor|xnr")
    ff = ("dff", r"[^s]dff|^ff|^dff")
    scanff = ("sdff", r"sdff|sff")
    bufferInv = ("bufferinv", r"^hib\ds\d|^ib\d\w\d")
    or_and = ("or_and", r"oa")
    and_or = ("and_or", r"ao")
    mux = ("mux", r"mux|mx")
    # latch = ('latch', r'latch')

    bias0 = ("bias0", r"1'b0")
    bias1 = ("bias1", r"1'b1")
    adder = ("adder", r"add")

    @property
    def isFF(self):
        return self in [NodeType.scanff, NodeType.ff]

    @property
    def isOut(self):
        return self == NodeType.output

    @property
    def inIn(self):
        return self == NodeType.input

    def __lt__(self, other):
        if hasattr(NodeType, "input") and hasattr(NodeType, "output"):
            if self == NodeType.input or other == NodeType.output:
                return True
            elif other == NodeType.input or self == NodeType.output:
                return False
        return self.value < other.value

    def __le__(self, other):
        if hasattr(NodeType, "input") and hasattr(NodeType, "output"):
            if self == NodeType.input or other == NodeType.output:
                return True
            elif other == NodeType.input or self == NodeType.output:
                return False
        return self.value <= other.value

    def __gt__(self, other):
        if hasattr(NodeType, "output"):
            if self == NodeType.output:
                return True
            elif other == NodeType.output:
                return False
        return self.value > other.value

    def __ge__(self, other):
        if hasattr(NodeType, "output"):
            if self == NodeType.output:
                return True
            elif other == NodeType.output:
                return False
        return self.value >= other.value


class NodeAttributes(dict):
    @property
    def faultCounts(self):
        return self["faultCounts"]

    @staticmethod
    def defaultControlPointAttributes():
        return NodeAttributes(logicDepth=0, control0=1, control1=1, observe=2)

    @property
    def moduleName(self):
        return self.get("moduleName", None)

    @property
    def nodeType(self) -> NodeType:
        return self.get("nodeType", None)

    @property
    def ports(self):
        p = self.get("ports", None)
        if p is None:
            self["ports"] = set()
        return self["ports"]

    @property
    def portDirections(self):
        p = self.get("portDirections", None)
        if p is None:
            self["portDirections"] = set()
        return self["portDirections"]

    def addPort(self, port):
        if "ports" not in self.keys():
            self["ports"] = set()
        self["ports"].add(port)

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # self.node_type: NodeType = NodeType(kwargs.get('node_type', None))
        self["faultCounts"] = {}

        if self.moduleName is not None and self.nodeType is None:
            self["nodeType"] = NodeType.fromString(self.moduleName)

    def __hash__(self):
        return hash(f"{self.__str__()} {self.__dict__}")


# class EdgeType(Enum):
#     scan = "scan"


class EdgeAttributes(dict):
    @property
    def nets(self):
        return self["nets"]

    @property
    def sourcePort(self):
        return self["sourcePort"]

    @property
    def targetPort(self):
        return self["targetPort"]

    def __init__(self, nets: set, sourcePort=None, targetPort=None, **kwargs):
        super().__init__(**kwargs)
        self["nets"] = nets
        self["sourcePort"] = sourcePort
        self["targetPort"] = targetPort
        # self.switching_probability: Optional[float] = kwargs.get('switching_probability', None)

    def __str__(self):
        nets = self.get("nets", set())
        if len(nets) > 0:
            out = ",".join([f"{nId}" for nId, nType in nets])
        else:
            out = "EdgeAttribute()"
        return out

    def __repr__(self):
        return self.__str__()

    def __hash__(self):
        return hash(f"{self.__str__()} {self.__dict__}")


class GraphAttributes(dict):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    def __hash__(self):
        return hash(f"{self.__dict__}")


GraphLabelerFunc = Callable[
    [Union[GraphAttributes, NodeAttributes, EdgeAttributes]], Union[float, int]
]


class GraphLabelMode(Enum):
    node = "node"
    graph = "graph"
    edge = "edge"


class NodeEntry:
    # r'IN\d*|D\d*|INP\d*|RSTB\d*|S\d*|CLK\d*|[A-P]\d*|CI'  # ['D', 'CLK', 'IN', 'INP', 'RSTB', 'S', 'CI'] added 'A' - 'P' for benchmark parsing
    DEF_INPUT_EXP = RegexConstants.PIN_INPUT_EXP

    # r'Q\d*|QN\d*|Z\d*|ZN\d*|Y\d*|CO'  # ['Q', 'QN', 'Z', 'ZN', 'CO'] added 'Y' for benchmark parsing
    DEF_OUTPUT_EXP = RegexConstants.PIN_OUTPUT_EXP

    # r'IN\d*|D\d*|INP\d*|RSTB\d*|CLK\d*|[A-P]\d*|CI'
    ADDER_INPUT_EXP = RegexConstants.ADDER_INPUT_EXP

    # r'Q\d*|QN\d*|Z\d*|ZN\d*|Y\d*|CO|S\d*'
    ADDER_OUTPUT_EXP = RegexConstants.ADDER_OUTPUT_EXP

    @property
    def moduleName(self):
        return self.attributes.get("moduleName", None)

    @property
    def ports(self):
        return self.attributes.ports

    @property
    def nodeType(self):
        return self.attributes.nodeType

    def portDirection(self, port):
        try:
            direction = self.ports[port]
            if direction is None:
                if self.nodeType == NodeType.adder:
                    IN_EXP = self.ADDER_INPUT_EXP
                    OUT_EXP = self.ADDER_OUTPUT_EXP
                else:
                    IN_EXP = self.DEF_INPUT_EXP
                    OUT_EXP = self.DEF_OUTPUT_EXP

                p = port.upper()
                isIn = re.fullmatch(IN_EXP, p) is not None
                isOut = re.fullmatch(OUT_EXP, p) is not None
                valid = isIn != isOut
                assert valid, f"Error in expressions, equivalence for port: {port}"
                return "input" if isIn else "output"
            return direction
        except KeyError:
            raise Exception(f"Port not on node: {port}")

    def portIsInput(self, port):
        return self.portDirection(port) == "input"

    def portIsOutput(self, port):
        return self.portDirection(port) == "output"

    def __init__(
        self,
        name: str,
        identifier: NodeID,
        nodeType: NodeType = None,
    ):
        self.identifier = identifier

        if name is not None and nodeType is None:
            _nodeType = NodeType.fromString(name)
        else:
            _nodeType = nodeType

        self.attributes = NodeAttributes(
            moduleName=name,
            identifier=self.identifier,
            nodeType=_nodeType,
            isKeyed=int(re.search(r"key", name.lower()) is not None),
            ports=OrderedDict(),
        )

    def addPort(self, port, direction=None):
        self.ports[port] = direction


class PIMode(Enum):
    single = "single"
    primaryLabeled = "primaryLabeled"
    netMatch = "netMatch"


class NetEntry:
    def __init__(
        self,
        identifier: NetID,
        netType: str,
        piMode: PIMode,
        leavingFrom: Set[NodePort] = None,
        goingTo: Set[NodePort] = None,
    ):
        if leavingFrom is None:
            leavingFrom = set()
        if goingTo is None:
            goingTo = set()
        self.identifier = identifier
        self.netType = netType
        self.leavingFrom = leavingFrom
        self.goingTo = goingTo
        self.aliases = set()

        if self.netType == "input":
            self.leavingFrom.add(
                NodePort(
                    nodeIdForPrimaryIO("pi", self.identifier, piMode), self.identifier
                )
            )
        elif self.netType == "output":
            self.goingTo.add(
                NodePort(
                    nodeIdForPrimaryIO("po", self.identifier, piMode), self.identifier
                )
            )

    def addAlias(self, aliasIdentifier):
        if self.identifier != aliasIdentifier:
            self.aliases.add(aliasIdentifier)

    def addAliases(self, aliasIds: Union[list, set]):
        self.aliases.update(aliasIds)
        self.aliases = self.aliases.difference([self.identifier])

    # def attributeDict(self):
    #     return dict(nets=(self.identifier, self.netType))


def nodeIdForPrimaryIO(io, net, primaryIOmode: PIMode):
    """

    Args:
        io ():
        net ():
        primaryIOmode ():

    Returns:

    """
    if io.lower() in ["pi", "po"]:
        if primaryIOmode == PIMode.single:
            return f"__{io.upper()}__"
        elif PIMode == PIMode.primaryLabeled:
            return f"__{io.upper()}__{net}"
        return f"{net}"
    return net


def parseLibrary(path: Path):
    netlist = path.read_text()
    netlist = re.sub("\n", " ", netlist)
    entries = re.findall(
        r"(module|input|output)\s+([_\w,\s\[\]]+)\s*;?|(endmodule)", netlist
    )
    modules = {}
    activeModule = None
    for e0, e1, e2 in entries:
        if e0 == "module":
            activeModule = e1.strip(" \n()")
            modules[activeModule] = dict(inputs=[], outputs=[])
        elif e0 == "input":
            try:
                ports = [i.strip(" ") for i in e1.split(",")]
                modules[activeModule]["inputs"].extend(ports)
            except KeyError:
                pass
        elif e0 == "output":
            try:
                ports = [o.strip(" ") for o in e1.split(",")]
                modules[activeModule]["outputs"].extend(ports)
            except KeyError:
                pass
        elif e2 == "endmodule":
            activeModule = None
    return modules


class BaseGraphReader(Protocol):
    nodes: Dict[str, NodeEntry] = dict()
    nets: Dict[str, NetEntry] = dict()
    ports = set()
    assignments: Dict[str, str] = dict()
    moduleName: Optional[str] = None
    library = None

    # r"[10]'b[10]"
    BIAS_EXP = RegexConstants.BIAS_EXP

    # r'[\\\/\\\w\d\-]+'
    ID_EXP = RegexConstants.ID_EXP
    # r'[\\\/\\\w\d\s\-,]+'
    ID_LIST = RegexConstants.ID_LIST
    # r'[\\\/\\\[\]\w\d\-]+'
    ID_BRACKETED = RegexConstants.ID_BUS_EXP
    # r'[\\\/\\\[\]\w\d\s\-,]+'
    ID_BRACKETED_LIST = RegexConstants.ID_BUS_EXP_LIST
    # r'\s*\[(\d+\:\d+)\]'
    RANGE = RegexConstants.RANGE
    # r'[\/\\\[\]\d\w\s,\(\)\.]+'
    PORT_LIST = RegexConstants.PORT_LIST

    # r'[\s\n]+'
    NEWLINE = RegexConstants.NEWLINE
    # r'module\s+(' + ID_EXP + r')\s*\((' + ID_LIST + ')\)\s*\;'
    MODULE_EXP = RegexConstants.MODULE_EXP
    # r'input(?:' + RANGE + ')?\s+(' + ID_BRACKETED_LIST + ')\s*\;'
    INPUT_EXP = RegexConstants.INPUT_EXP
    # r'output(?:' + RANGE + ')?\s+(' + ID_BRACKETED_LIST + ')\s*\;'
    OUTPUT_EXP = RegexConstants.OUTPUT_EXP
    # r'wire(?:' + RANGE + ')?\s+(' + ID_BRACKETED_LIST + ')\s*\;'
    WIRE_EXP = RegexConstants.WIRE_EXP
    # r'assign\s+(' + ID_BRACKETED + r')\s*=\s*(' + ID_BRACKETED + '|' + BIAS_EXP + r')\s*\;'
    ASSIGN_EXP = RegexConstants.ASSIGN_EXP
    # r'((?![module])' + ID_EXP + r')\s+(' + ID_BRACKETED + r')\s*\(\s*(' + PORT_LIST + ')\s*\)\s*\;'
    ENTRY_EXP = RegexConstants.ENTRY_EXP
    # r"\.([A-z]+\d*)\((.+)\)"
    PORT_DECLARATION_EXP = RegexConstants.PORT_DECLARATION_EXP

    def _initSelf(self, piMode: PIMode):
        self.nodes: Dict[str, NodeEntry] = dict()
        self.nets: Dict[str, NetEntry] = dict()
        self.ports = set()
        self.assignments: Dict[str, str] = dict()
        self.moduleName = None
        self.library = None
        self.piMode = piMode

    def rangeValsFromString(self, string):
        numVals = [int(s.strip("[]()")) for s in string.split(":")]
        numVals = [int(n) for n in numVals]
        numVals.sort()
        return numVals

    def createNetsFromRange(self, netBaseNames, rangeCtx):
        numVals = self.rangeValsFromString(rangeCtx.getText())
        if len(numVals) != 2:
            raise Exception(f"Invalid number of dimensions {numVals}")
        _nets = set([])
        for net in netBaseNames:
            for i in range(numVals[0], numVals[1] + 1):
                _nets.add(f"{net}[{i}]")
        return _nets

    def addNet(self, netIdentifier, netType):
        try:
            originalNetIdentifier = self.assignments[netIdentifier]
            self.nets[originalNetIdentifier].addAlias(netIdentifier)
        except KeyError:
            if self.nets.get(netIdentifier, None) is None:
                self.nets[netIdentifier] = NetEntry(
                    identifier=netIdentifier, netType=netType, piMode=self.piMode
                )

    def addInOutNetNodes(self, ports, portType):
        for net in ports:
            if net not in self.nets.keys():
                self.addNet(netIdentifier=net, netType=portType)
            nid = nodeIdForPrimaryIO(
                "pi" if portType == "input" else "po", net, self.piMode
            )

            if portType == "input":
                ntype = NodeType.input
            elif portType == "output":
                ntype = NodeType.output
            else:
                # NodeEntry will try to figure out based on node ID
                ntype = None

            nodeEntry = NodeEntry(name=nid, identifier=nid, nodeType=ntype)
            if nodeEntry.identifier not in self.nodes.keys():
                self.nodes[nodeEntry.identifier] = nodeEntry
            direction = "output" if portType == "input" else "input"
            self.nodes[nodeEntry.identifier].addPort(net, direction)

    def addModule(self, moduleName, moduleID, portDeclarations):
        node = NodeEntry(name=moduleName, identifier=moduleID)

        if self.library is not None:
            for i in self.library[moduleName]["inputs"]:
                node.addPort(i, "input")
            for o in self.library[moduleName]["outputs"]:
                node.addPort(o, "output")

        for portDec in portDeclarations:
            matches = re.search(self.PORT_DECLARATION_EXP, portDec)
            pin, net = matches.groups()
            pin = pin.strip(" ")
            net = net.strip(" ")
            if pin not in node.ports.keys():
                node.addPort(pin, None)

            # Checks for any existing assignments and resolves to primary declaration
            # Loop resolves multi-level assignments
            while net in self.assignments:
                net = self.assignments[net]

            nodePort = NodePort(moduleID, pin)

            if net == "1'b0" or net == "1'b1":
                nodeType = NodeType.fromString(net)
                self.addBias(nodeType, nodeType.name)
            elif node.portIsInput(pin):
                self.nets[net].goingTo.add(nodePort)
            elif node.portIsOutput(pin):
                self.nets[net].leavingFrom.add(nodePort)
                if len(self.nets[net].leavingFrom) > 1:
                    raise Exception(f"Defining more than 1 output for net {net}")
            else:
                raise Exception(f"unsupported port {pin}")

        if node.identifier in self.nodes.keys():
            raise Exception(
                f"node already present in node list: ({node.moduleName}, {node.identifier})"
            )

        self.nodes[node.identifier] = node

    def setModuleName(self, txt: str):
        if self.moduleName is None:
            self.moduleName = txt

    def addBias(self, nodeType: NodeType, netID: NetID):
        if nodeType not in [NodeType.bias0, NodeType.bias1]:
            return

        if nodeType.name not in self.nodes.keys():
            self.nodes[nodeType.name] = NodeEntry(
                nodeType.name, nodeType.value, nodeType
            )

        if nodeType.name not in self.nets.keys():
            self.nets[nodeType.name] = NetEntry(
                nodeType.name, nodeType.input.value, piMode=self.piMode
            )

        if netID not in self.nets.keys():
            self.nets[netID] = NetEntry(netID, nodeType.value, piMode=self.piMode)

        self.nets[netID].leavingFrom.add(NodePort(nodeType.value, nodeType.value))

    def addAssignment(self, assignment: Union[str, tuple]):
        if isinstance(assignment, str):
            assignedTo, identifier = assignment.split("=")
        else:
            assignedTo, identifier = assignment

        try:
            identifierType = NodeType.fromString(identifier)
            if identifierType in [NodeType.bias0, NodeType.bias1]:
                self.addBias(identifierType, assignedTo)
                identifier = identifierType.value
        except:
            pass

        self.assignments[assignedTo] = identifier

        # TODO: consider net/node types when resolving assignments and creating nodes/edges

        aliases = {assignedTo, identifier}
        while identifier in self.assignments:
            aliases.add(identifier)
            identifier = self.assignments[identifier]

        for netId in aliases:
            net = self.nets[netId]
            net.addAliases(aliases)


class RegExpReader(BaseGraphReader):
    def __init__(self, piMode: PIMode, verbose=False):
        self._initSelf(piMode=piMode)
        self.verbose = verbose

    def processInOutWire(self, inputs):
        ins = []
        for i in inputs:
            bits, _nets = i
            if len(bits) > 0:
                r = [int(b.strip("\n ")) for b in bits.split(":")]
                r.sort()
                nLow, nHigh = r
            else:
                nLow, nHigh = None, None

            if "," in _nets:
                _nets = [m for m in re.sub(r"[\s\n]+", "", _nets).split(",")]
            else:
                _nets = [_nets]

            if nHigh is not None and nLow is not None:
                _nets = [f"{net}[{n}]" for net in _nets for n in range(nLow, nHigh + 1)]

            ins.extend(_nets)
        return ins

    def parsePort(self, p):
        m = re.search(self.PORT_DECLARATION_EXP, p)
        pin, net = m.groups()
        return pin, net

    def parseGateNetlistFile(self, path: Path, libraryPath: Path = None, verbose=False):
        netlist = path.read_text()
        netlist = re.sub("\n", " ", netlist)

        self.library = None if libraryPath is None else parseLibrary(libraryPath)

        name, _ = re.search(self.MODULE_EXP, netlist).groups()
        self.setModuleName(name)

        inputs = re.findall(self.INPUT_EXP, netlist)
        assigns = re.findall(self.ASSIGN_EXP, netlist)
        outputs = re.findall(self.OUTPUT_EXP, netlist)
        entries = re.findall(self.ENTRY_EXP, netlist)
        wires = re.findall(self.WIRE_EXP, netlist)

        self.addInOutNetNodes(self.processInOutWire(inputs), "input")
        self.addInOutNetNodes(self.processInOutWire(outputs), "output")

        for w in self.processInOutWire(wires):
            self.addNet(w, "wire")

        for assignment in assigns:
            # TODO: Handle assignment of biases
            self.addAssignment(assignment)

        if verbose:
            entries = tqdm.tqdm(entries, desc=f"Reading {path.name}")

        for entry in entries:
            moduleName, identifier, portlist = entry
            if "module" == moduleName:
                continue
            self.addModule(
                moduleName, identifier, [p.strip(" ") for p in portlist.split(",")]
            )

        # Resolve aliased input and output nets
        for assignedTo, identifier in self.assignments.items():
            net = self.nets[identifier]
            for a in net.aliases:
                aliasNet = self.nets[a]

                if net.netType == "input" and aliasNet.netType == "output":
                    net.goingTo.update(aliasNet.goingTo)
                    aliasNet.leavingFrom.update(net.leavingFrom)
                elif net.netType == "input" and aliasNet.netType == "wire":
                    net.goingTo.update(aliasNet.goingTo)
                    aliasNet.leavingFrom.update(net.leavingFrom)
                    aliasNet.goingTo.update(net.goingTo)
                elif net.netType == "input" and aliasNet.netType == "input":
                    net.goingTo.update(aliasNet.goingTo)
                    aliasNet.goingTo.update(net.goingTo)

                elif net.netType == "output" and aliasNet.netType == "input":
                    net.leavingFrom.update(aliasNet.leavingFrom)
                    aliasNet.goingTo.update(net.goingTo)
                elif net.netType == "output" and aliasNet.netType == "wire":
                    net.leavingFrom.update(aliasNet.leavingFrom)
                    aliasNet.leavingFrom.update(net.leavingFrom)
                    aliasNet.goingTo.update(net.goingTo)
                elif net.netType == "output" and aliasNet.netType == "output":
                    net.leavingFrom.update(aliasNet.leavingFrom)
                    aliasNet.leavingFrom.update(net.leavingFrom)

                elif net.netType == "wire" and aliasNet.netType == "input":
                    aliasNet.goingTo.update(net.goingTo)
                    net.goingTo.update(aliasNet.goingTo)
                    net.leavingFrom.update(aliasNet.leavingFrom)
                elif net.netType == "wire" and aliasNet.netType == "output":
                    aliasNet.leavingFrom.update(net.leavingFrom)
                    net.leavingFrom.update(aliasNet.leavingFrom)
                    net.goingTo.update(aliasNet.goingTo)
                elif net.netType == "wire" and aliasNet.netType == "wire":
                    net.leavingFrom.update(aliasNet.leavingFrom)
                    aliasNet.leavingFrom.update(net.leavingFrom)
                    net.goingTo.update(aliasNet.goingTo)
                    aliasNet.goingTo.update(net.goingTo)

                else:
                    raise NotImplementedError

                if len(net.leavingFrom) > 1 or len(aliasNet.leavingFrom) > 1:
                    raise Exception()


class StuckAtFaultType(Enum):
    stuck_at_0 = "sa0"
    stuck_at_1 = "sa1"

    def __str__(self):
        return self.value

    def __repr__(self):
        return self.value

    def __lt__(self, other):
        return self.value < other.value

    def __gt__(self, other):
        return self.value > other.value


class ATPGFaultType(Enum):
    # major classes
    detected = "DT"
    possiblyDetected = "PT"
    undetectable = "UD"
    atpgUntestable = "AU"
    notDetected = "ND"

    # Detected Subclasses
    detectedBySim = "DS"
    detectedByImp = "DI"

    # Possibly detected subclasses
    atpgUntestablePossiblyDetected = "AP"
    notAnalyzedPossiblyDetected = "NP"

    # Undetectable subclasses
    undetectableUnused = "UU"
    undetectableUnobserved = "UO"
    undetectableTied = "UT"
    undetectableBlocked = "UB"
    undetectableRedundant = "UR"

    # ATPG untestable subclasses
    atpgUntestableNotDetected = "AN"

    # Not Detected subclasses
    notControlled = "NC"
    notObserved = "NO"

    @property
    def isDetected(self) -> bool:
        return self in [
            ATPGFaultType.detected,
            ATPGFaultType.detectedBySim,
            ATPGFaultType.detectedByImp,
        ]

    @property
    def isPossiblyDetected(self) -> bool:
        return self in [
            ATPGFaultType.possiblyDetected,
            ATPGFaultType.atpgUntestablePossiblyDetected,
            ATPGFaultType.notAnalyzedPossiblyDetected,
        ]

    @property
    def isUndetectable(self) -> bool:
        return self in [
            ATPGFaultType.undetectable,
            ATPGFaultType.undetectableUnused,
            ATPGFaultType.undetectableUnobserved,
            ATPGFaultType.undetectableTied,
            ATPGFaultType.undetectableBlocked,
            ATPGFaultType.undetectableRedundant,
        ]

    @property
    def isUntestable(self):
        return self in [
            ATPGFaultType.atpgUntestable,
            ATPGFaultType.atpgUntestableNotDetected,
        ]

    @property
    def isNotDetected(self) -> bool:
        return self in [
            ATPGFaultType.notDetected,
            ATPGFaultType.atpgUntestableNotDetected,
        ]

    def __repr__(self):
        return self.name

    def __str__(self):
        return self.name

    def __lt__(self, other):
        return self.value < other.value

    def __gt__(self, other):
        return self.value > other.value


class GraphType(Enum):
    undirected = "undirected"
    directed = "directed"
    directedAcyclic = "directedAcyclic"

    def __str__(self):
        return self.value

    def __repr__(self):
        return self.__str__()


class GraphLayout:
    @staticmethod
    def nudge(pos, x_shift, y_shift):
        return {n: (x + x_shift, y + y_shift) for n, (x, y) in pos.items()}

    # class gt(Enum):
    #     kamada = 'kamada'
    #     spring = 'spring'
    #     fruchterman = 'fruchterman'
    #     planar = 'planar'
    #     shell = 'shell'
    #
    #     @property
    #     def func(self):
    #         if self == GraphLayout.gt.kamada:
    #             return gt_draw.sfdp_layout
    #         elif self == GraphLayout.gt.spring:
    #             return gt_draw.arf_layout
    #         elif self == GraphLayout.gt.fruchterman:
    #             return gt_draw.fruchterman_reingold_layout
    #         elif self == GraphLayout.gt.planar:
    #             return gt_draw.planar_layout
    #         elif self == GraphLayout.gt.shell:
    #             return gt_draw.radial_tree_layout
    #         else:
    #             return gt_draw.sfdp_layout

    class nx(Enum):
        kamada = "kamada"
        spring = "spring"
        fruchterman = "fruchterman"
        planar = "planar"
        shell = "shell"
        spectral = "spectral"
        spiral = "spiral"
        circular = "circular"
        random = "random"
        rescale = "rescale"
        bipartite = "bipartite"
        multipartite = "multipartite"

        @property
        def func(self):
            if self == GraphLayout.nx.kamada:
                return nx.layout.kamada_kawai_layout
            elif self == GraphLayout.nx.spring:
                return nx.layout.spring_layout
            elif self == GraphLayout.nx.fruchterman:
                return nx.layout.fruchterman_reingold_layout
            elif self == GraphLayout.nx.planar:
                return nx.layout.planar_layout
            elif self == GraphLayout.nx.shell:
                return nx.layout.shell_layout
            elif self == GraphLayout.nx.spectral:
                return nx.layout.spectral_layout
            elif self == GraphLayout.nx.spiral:
                return nx.layout.spiral_layout
            elif self == GraphLayout.nx.circular:
                return nx.layout.circular_layout
            elif self == GraphLayout.nx.random:
                return nx.layout.random_layout
            elif self == GraphLayout.nx.rescale:
                return nx.layout.rescale_layout
            elif self == GraphLayout.nx.multipartite:
                return nx.layout.multipartite_layout
            elif self == GraphLayout.nx.bipartite:
                return nx.layout.bipartite_layout
            else:
                return nx.layout.spring_layout


class DataHelpers:
    @staticmethod
    def readSCOAP(path: Path) -> ScoapData:
        """
        Reads SCOAP output data from Synopsys

        :param path: path to SCOAP file
        :return: SoapData instance
        """
        return ScoapData.fromPath(path)

    @staticmethod
    def readSwitchingProbabilities(path: Path) -> pd.DataFrame:
        """
        Reads switching probabilities from Synopsys tooling

        Net Attributes
            - a -- Switching activity information annotated on net
            - d -- Default switching activity information on net

        :param path: path to the switching probability file
        :return: A pandas DataFrame object
        """

        # switchingPath = Path('unittests/switching/wb_conmax_top_power.out')
        switchingText = path.read_text().split("\n")
        startLine = None
        endLine = None
        for i, line in enumerate(switchingText):
            if (
                re.search(r"Net\s+Net\s+Load\s+Prob\.\s+Rate\s+Power\s+Attrs", line)
                is not None
            ):
                startLine = i + 2
                break

        for i in range(len(switchingText) - 1, 0, -1):
            line = switchingText[i]
            if re.search(r"-+", line):
                endLine = i
                break

        dataLines = switchingText[startLine:endLine]
        splitData = []
        for line in dataLines:
            splitData.append(re.split(r"\s+", line))
        data = pd.DataFrame(
            splitData,
            columns=[
                "net",
                "totalNetLoad",
                "staticProb",
                "toggleRate",
                "switchingPower",
                "attrs",
            ],
        )
        # Resolve single entry split into 2 lines
        removeRows = []
        for i, row in data.iterrows():
            if row["net"] == "":
                removeRows.append(i)
                r = 1
                c = 0
                while not pd.isna(data.iloc[i - 1, c]):
                    c += 1
                while pd.isna(data.iloc[i, r]) or data.iloc[i, r] == "":
                    r += 1
                for ci in range(c, len(data.columns)):
                    data.iloc[i - 1, ci] = data.iloc[i, r]
                    r += 1
        data = data.drop(removeRows).reset_index(drop=True)
        data = data.apply(pd.to_numeric, errors="ignore")
        return data

    @staticmethod
    def readFaultReport(path: Path) -> pd.DataFrame:
        """
        Reads a fault report output from TetraMax


        Assumes the file contains a single line of text (no newline characters) and the reported values
        comes in the form of 3-tuple entries.

        :param path: path to the fault report file
        :return: A pandas dataframe containing the fault report data
        """
        s = path.read_text()
        tokens = [
            {
                k: v
                for k, v in zip(
                    ["stuckAt", "faultType", "pin"], re.split(r"\s+", _s.strip("\n{} "))
                )
            }
            for _s in re.split(r"\n", s)
        ]

        # if len(tokens) % 3 != 0:
        #     print(f"tokens not in tuples of 3")

        data = pd.DataFrame(tokens)
        data.dropna(inplace=True)
        data.stuckAt = data.stuckAt.apply(lambda x: StuckAtFaultType(x))
        data.faultType = data.faultType.apply(lambda x: ATPGFaultType(x))
        data.sort_values(by="pin", inplace=True)
        data = data[["pin", "stuckAt", "faultType"]]
        return data


# class LogicDepthVisitor(gt_search.BFSVisitor):
#     """ Visitor object to calculate longest paths between nodes using breadth first search"""
#
#     def __init__(self, G: gt.Graph):
#         self.properties = G.vp.all
#         self.G = G
#         self.depths = dict.fromkeys([self._getNodeId(u) for u in G.vertices()], 0)
#
#     def _getNodeId(self, u):
#         return self.properties[u]['identifier']
#
#     def discover_vertex(self, u):
#
#         uId = self._getNodeId(u)
#
#         if len(self.G.get_in_neighbors(u)) == 0 or self.properties[u]['nodeType'] in [NodeType.input, NodeType.scanff]:
#             self.depths[uId] = 0
#
#         nDepth = self.depths[uId] + 1
#         neighbors = self.G.get_out_neighbors(u)
#         for n in neighbors:
#             nId = self._getNodeId(n)
#             if nDepth > self.depths[nId] and self.properties[n]['nodeType'] not in [NodeType.input, NodeType.scanff]:
#                 self.depths[nId] = nDepth
#
#         # print(f"---- disc. {u} {self.properties[u]['identifier']:<15} {self.depths[uId]:>4} {neighbors}")


def _stringsFromNodeList(nList, graphReader):
    nodes = [f"{n} ({graphReader.nodes[n.nodeId].nodeType.value})" for n in nList]
    if len(nodes) == 1:
        return nodes[0]
    return nodes


def __def_weight(u, v, data, weight="weight"):
    return data.get(weight, 1)


def __def_weight_multi(u, v, d, weight="weight"):
    return min(attr.get(weight, 1) for attr in d.values())


def _weight_function(G, weight):
    """

    Args:
        G ():
        weight ():

    Returns:

    """
    if callable(weight):
        return weight
    # If the weight keyword argument is not callable, we assume it is a
    # string representing the edge attribute containing the weight of
    # the edge.
    if G.is_multigraph():
        return __def_weight_multi
    return __def_weight


def netlist_bfs_edges(
    G,
    source,
    skip=None,
    consider_leaf=None,
    depth_limit=None,
    sort_neighbors=None,
    reverse=False,
):
    # TODO: raise exception if graph is cyclic

    if reverse and G.is_directed():
        successors = G.predecessors
    else:
        successors = G.neighbors

    depths = {}

    def _netlist_generic_bfs_edges(
        _G,
        _source,
        _neighbors=None,
        _skip=None,
        _consider_leaf=None,
        _depth_limit=None,
        _sort_neighbors=None,
    ):
        if callable(_sort_neighbors):
            _neighbors = _neighbors
            _neighbors = lambda node: iter(_sort_neighbors(_neighbors(node)))
        visited = {_source}
        if _depth_limit is None:
            _depth_limit = len(_G)
        queue = deque([(_source, _depth_limit, 0, _neighbors(_source))])
        while queue:
            _parent, depth_now, currDepth, _children = queue[0]
            depths[_parent] = currDepth
            forcedLeaf = (
                _consider_leaf(_parent, _G.nodes[_parent])
                if _consider_leaf is not None
                else False
            )
            try:
                child = next(_children)
                if _skip is not None and _skip(child, _G.nodes[child]):
                    # queue.popleft()
                    # queue.insert(0, (_parent, depth_now, iter(list(_children) + list(_neighbors(child)))))
                    # continue
                    raise NotImplementedError
                if _parent != _source and forcedLeaf:
                    raise StopIteration
                if child not in visited:
                    yield _parent, child
                    visited.add(child)
                    if depth_now > 1:
                        queue.append(
                            (child, depth_now - 1, currDepth + 1, _neighbors(child))
                        )
            except StopIteration:
                queue.popleft()

    return (
        _netlist_generic_bfs_edges(
            _G=G,
            _source=source,
            _neighbors=successors,
            _skip=skip,
            _consider_leaf=consider_leaf,
            _depth_limit=depth_limit,
            _sort_neighbors=sort_neighbors,
        ),
        depths,
    )


def netlist_dfs_edges(
    G,
    source,
    skip=None,
    consider_leaf=None,
    depth_limit=None,
    sort_neighbors=None,
):
    depths = {source: 0}

    def _netlist_generic_dfs_edges(
        _G,
        _source,
        _skip=None,
        _consider_leaf=None,
        _depth_limit=None,
        _sort_neighbors=None,
    ):
        if source is None:
            # edges for all components
            nodes = G
        else:
            # edges for components with source
            nodes = [source]

        visited = set()
        if _depth_limit is None:
            _depth_limit = len(G)
        maxDepth = len(G)
        for start in nodes:
            if start in visited:
                continue
            visited.add(start)
            stack = [(start, _depth_limit, iter(G[start]))]
            while stack:
                _parent, depth_now, children = stack[-1]
                d = maxDepth - depth_now
                forcedLeaf = (
                    _consider_leaf(_parent, _G.nodes[_parent])
                    if _consider_leaf is not None
                    else False
                )
                try:
                    child = next(children)
                    if _skip is not None and _skip(child, _G.nodes[child]):
                        raise NotImplementedError
                    if _parent != _source and forcedLeaf:
                        raise StopIteration
                    if child not in visited:
                        depths[child] = d + 1
                        yield _parent, child
                        visited.add(child)
                        if depth_now > 1:
                            stack.append((child, depth_now - 1, iter(G[child])))
                except StopIteration:
                    stack.pop()

    return (
        _netlist_generic_dfs_edges(
            _G=G,
            _source=source,
            _skip=skip,
            _consider_leaf=consider_leaf,
            _depth_limit=depth_limit,
            _sort_neighbors=sort_neighbors,
        ),
        depths,
    )


def netlist_bfs_tree(
    G,
    source,
    skip: Callable[[str, dict], bool] = None,
    consider_leaf: Callable[[str, dict], bool] = None,
    reverse=False,
    depth_limit=None,
    sort_neighbors=None,
):
    T = nx.DiGraph()
    T.add_node(source)
    edges_gen, depths = netlist_bfs_edges(
        G,
        source,
        skip=skip,
        consider_leaf=consider_leaf,
        reverse=reverse,
        depth_limit=depth_limit,
        sort_neighbors=sort_neighbors,
    )
    T.add_edges_from(edges_gen)
    for n, d in depths.items():
        T.nodes[n]["depth"] = d
    return T


def netlist_dfs_tree(
    G,
    source,
    skip: Callable[[str, dict], bool] = None,
    consider_leaf: Callable[[str, dict], bool] = None,
    depth_limit=None,
    sort_neighbors=None,
):
    T = nx.DiGraph()
    if source is None:
        T.add_nodes_from(G)
    else:
        T.add_node(source)

    edges_gen, depths = netlist_dfs_edges(
        G,
        source,
        skip=skip,
        consider_leaf=consider_leaf,
        depth_limit=depth_limit,
        sort_neighbors=sort_neighbors,
    )
    T.add_edges_from(edges_gen)
    for n, d in depths.items():
        T.nodes[n]["depth"] = d
    return T


def getDAGTreesBFS(
    G: nx.Graph,
    sources,
    consider_leaf=None,
):
    for source in sources:
        yield source, netlist_bfs_tree(
            G,
            source=source,
            consider_leaf=consider_leaf,
        )


def getDAGTreesDFS(
    G: nx.Graph,
    sources,
    consider_leaf=None,
):
    for source in sources:
        yield source, netlist_dfs_tree(G, source=source, consider_leaf=consider_leaf)


def __depths(G, root, weight, consider_leaf):
    _, tree = next(getDAGTreesBFS(G, [root], consider_leaf))
    depths = {n: 0 for n in tree.nodes}
    subgraph = nx.subgraph_view(
        G,
        filter_node=lambda n: n in tree.nodes,
        filter_edge=lambda u, v: (u == root or not G.nodes[u]["nodeType"].isFF)
        and v != root,
    )
    assert nx.is_directed_acyclic_graph(subgraph), f"tree from {root} is cyclic"
    for u in nx.topological_sort(subgraph):
        for v in subgraph.neighbors(u):
            if G.nodes[v]["nodeType"].isFF:
                continue
            w = depths[u] + weight(u, v, subgraph.edges[(u, v)])
            depths[v] = max(depths[v], w)
    return depths


def _def_consider_leaf(n, attr):
    return "nodeType" in attr and attr["nodeType"].isFF


def _calcLogicDepths(
    G: nx.Graph,
    sources,
    depths=None,
    consider_leaf=_def_consider_leaf,
    verbose=False,
    weight="weight",
    ffDepthMode="zero",  # {zero, relative}
):
    depths = {n: 0 for n in G.nodes()} if depths is None else depths
    weight = _weight_function(G, weight)
    progress = tqdm.tqdm(desc="sources", total=len(sources)) if verbose else None

    if ffDepthMode == "relative":
        raise NotImplementedError
    elif ffDepthMode == "zero":
        sourceIter = iter(sources)
        with ProcessPoolExecutor() as pool:
            futures = {
                pool.submit(
                    __depths,
                    G=G,
                    root=source,
                    weight=weight,
                    consider_leaf=consider_leaf,
                )
                for source in itertools.islice(sourceIter, 200)
            }
            while futures:
                done, futures = concurrent.futures.wait(
                    futures, return_when=concurrent.futures.FIRST_COMPLETED
                )
                for fut in done:
                    for n, d in fut.result().items():
                        depths[n] = max(depths[n], d)
                    if progress is not None:
                        progress.update()
                for source in itertools.islice(sourceIter, len(done)):
                    futures.add(
                        pool.submit(
                            __depths,
                            G=G,
                            root=source,
                            weight=weight,
                            consider_leaf=consider_leaf,
                        )
                    )
    else:
        raise Exception(
            f"Invalid depth mode: {ffDepthMode} not one of [zero, relative]"
        )

    return depths


def calcLogicDepth(
    G: Union[nx.Graph, Graph],
    timeit=False,
    ffDepthMode="zero",
):
    """
    The combinational logic depth is defined as the maximum number of combinational logic levels,
    including buffers and inverters, between a port and an associated I/O register.

    Args:
        G ():
        timeit ():
        ffDepthMode ():

    Returns:
        dictionary of { node : [parents] }
    """

    if timeit:
        import time

        tic = time.time()
    if isinstance(G, (nx.Graph, Graph)):
        nxGraph: nx.DiGraph = G if isinstance(G, nx.Graph) else G.toNetworkX()
        depths = {n: 0 for n in nxGraph.nodes()}
        sources = [
            v for v, a in nxGraph.nodes.items() if a["nodeType"] == NodeType.input
        ]
        sources += [v for v in nxGraph.nodes() if nxGraph.nodes[v]["nodeType"].isFF]
        _calcLogicDepths(
            nxGraph, sources, depths=depths, ffDepthMode=ffDepthMode, verbose=timeit
        )
    else:
        raise Exception(
            f"Unsupported graph type: {G.__class__}, expects {nx.Graph.__class__} or {Graph.__class__}"
        )

    if timeit:
        print(f"Logic Depth Calc: {time.time() - tic:.5} secs")

    # pprint.pprint(depths)

    return depths


class Graph(object):
    """
    Netlist graph class that allows for reading verilog files
    # TODO: make Graph a subclass of nx.Graph

    """

    def __eq__(self, other: Graph):
        eq, _ = self.equality(other)
        return eq

    def equality(self, other: Graph):
        if self.numNodes != other.numNodes:
            return False, ("Number of nodes", [(self.numNodes, other.numNodes)])

        if self.numEdges != other.numEdges:
            return False, ("Number of edges", [(self.numEdges, other.numEdges)])

        if self.type != other.type:
            return False, ("Graph types", [(self.type, other.type)])

        if self.features != other.features:
            return False, ("Graph features", [(self.features, other.features)])

        unequalEdges = [
            (se, sea, other.edges[se])
            for se, sea in self.edges.items()
            if sea != other.edges[se]
        ]
        if len(unequalEdges) > 0:
            return False, ("Edges", unequalEdges)

        unequalNodes = [
            (n, v, other.nodes[n]) for n, v in self.nodes.items() if v != other.nodes[n]
        ]
        if len(unequalNodes) > 0:
            return False, ("Nodes", unequalNodes)
        return True, None

    @property
    def numNodes(self):
        return len(self.nodes)

    @property
    def numEdges(self):
        return len(self.edges)

    @property
    def inputNodeIds(self) -> List[NodeID]:
        return [
            nId
            for nId, attributes in self.nodes.items()
            if attributes.nodeType == NodeType.input
        ]

    @property
    def primaryInNets(self) -> List:
        return [
            list(attrs.ports.keys())[0]
            for _, attrs in self.nodes.items()
            if attrs.nodeType == NodeType.input
        ]

    @property
    def primaryOutNets(self):
        return [
            list(attrs.ports.keys())[0]
            for _, attrs in self.nodes.items()
            if attrs.nodeType == NodeType.output
        ]

    def iterInputNodeIds(self):
        for nId, attributes in self.nodes.items():
            if attributes.nodeType == NodeType.input:
                yield nId

    def __init__(
        self,
        name: str = "graph",
        graphType: GraphType = GraphType.directed,
        nodes: OrderedDict[NodeID, NodeAttributes] = None,
        edges: List[Tuple[NodePort, NodePort, EdgeAttributes]] = None,
        sourceFile=None,
    ):
        """
        Graph initializer
        """

        """
        Name of overall graph/design
        """
        self.name: str = name
        self.sourceFile: str = sourceFile

        """
        Type of graph, defaults to GraphType.directed
        """
        self.type = graphType

        self.features = GraphAttributes()

        """
        `nodes` is a dictionary of nodes.
        Each key is a node ID, and each value is a dictionary of attributes for that node
        """
        self.nodes: OrderedDict[NodeID, NodeAttributes] = (
            OrderedDict() if nodes is None else nodes
        )

        """
        `edges` is a list of tuples.  each tuple represents an edge of the form `(source_id, target_id, edge_attributes)`
        See EdgeDirection for valid direction values 
        """
        self.edges: OrderedDict[Tuple[NodePort, NodePort], EdgeAttributes] = (
            OrderedDict() if edges is None else edges
        )
        self.edgeLookup: OrderedDict[
            str, Set[Tuple[NodePort, NodePort]]
        ] = OrderedDict()

        self.libraryModules: Set[str] = set()

    @staticmethod
    def from_json(filename) -> Graph:
        # TODO: create a graph from json graph format file
        raise NotImplementedError

    @staticmethod
    def fromBenchmark(benchmark, **kwargs) -> Graph:
        if benchmark.rootDir is None:
            raise Exception(f"Benchmark must have rootPath set: {benchmark}")

        return Graph.fromVerilog(
            filePath=benchmark.vPath,
            scoapPath=benchmark.scoapPath,
            switchingPath=benchmark.switchPath,
            faultPath=benchmark.faultPath,
            **kwargs,
        )

    @staticmethod
    def verilogToJSON(
        rootDir: Path, libraryPath: Path = None, unpicklable=True, overwrite=False
    ):
        """
        Convenience function to convert a directory of verilog netlists to JSON graph files
        :param rootDir: Root path for design files
        :param libraryPath: Path to library file
        :param unpicklable: Whether to keep class and object information in the JSON pickle
        :param overwrite: flag to overwrite any existing JSON files with derived JSON path
        :return: Paths to the output JSON files
        """
        rootDir = (
            rootDir.expanduser()
        )  # Path("~/Dropbox (UFL)/STAMP/data/trojan-hypergraph").expanduser()
        libraryPath = (
            libraryPath.expanduser()
        )  # Path('~/Dropbox (UFL)/STAMP/data/library/lec25dscc25.v').expanduser()
        _iter = tqdm.tqdm(list(rootDir.rglob("*.v")))
        outPaths = []
        for verilogPath in _iter:
            _iter.set_description(f"{verilogPath.name}")
            outPath = verilogPath.parent.joinpath(
                f'{verilogPath.stem}{"-unpicklable" if unpicklable else ""}.json'
            )
            outPaths.append(outPath)
            if "lec" in verilogPath.name:
                continue
            try:
                G = Graph.fromVerilog(
                    verilogPath, libraryPath=libraryPath, verbose=False
                )
                G.to_json(outPath, unpicklable=unpicklable, overwrite=overwrite)
            except Exception as e:
                print(e, verilogPath)
        return outPaths

    @staticmethod
    def fromReader(
        graphReader: RegExpReader,
        sourceFileName,
        libraryPath=None,
        printSummaryTable=False,
    ):
        graph = Graph(name=graphReader.moduleName, sourceFile=sourceFileName)

        if libraryPath is not None:
            libText = libraryPath.read_text()
            graph.moduleNames = set(re.findall(r"module (\w+)", libText))

        summaryString = []

        for k, net in graphReader.nets.items():
            if printSummaryTable:
                summaryString.append(
                    [
                        f"{k}",
                        f"{net.netType}",
                        f"{_stringsFromNodeList(net.leavingFrom, graphReader)}",
                        f"{_stringsFromNodeList(net.goingTo, graphReader)}",
                        f'{net.aliases if len(net.aliases) > 0 else "-"}',
                    ]
                )
            for source in net.leavingFrom:
                graph.addNode(graphReader.nodes[source.nodeId])
                for target in net.goingTo:
                    graph.addNode(graphReader.nodes[target.nodeId])
                    graph.addEdge(
                        source,
                        target,
                        EdgeAttributes(nets={(net.identifier, net.netType)}),
                    )

        return graph, summaryString

    @staticmethod
    def fromVerilog(
        filePath: Path,
        scoapPath: Path = None,
        switchingPath: Path = None,
        faultPath: Path = None,
        libraryPath: Path = None,
        verbose=False,
        printSummaryTable=False,
        primaryIOmode: PIMode = PIMode.netMatch,
        ffDepthMode="zero",
    ) -> Graph:
        """
        This function primarily takes in a verilog file and returns a Graph

        Args:
            filePath (Path): path to the verilog file (required)
            scoapPath (Path): path to the SCOAP attributes file (optional)
            switchingPath (Path): path to the switching probabilities file (optional)
            faultPath (Path): path to the fault report file (optional)
            libraryPath (Path): path to library file to load module types (optional)
            verbose (bool): flag for verbose output, i.e. logging
            printSummaryTable (bool): prints a summary of the read graph as a pandas DataFrame
            primaryIOmode (PIMode): ['per-net','single'], defaults to 'per-net'. if 'single', creates a single primary input node and a single primary output node,
                each port is connected to a PI/PO net.  if 'per-net', each net gets a PI/PO node and is only connected to that net
            ffDepthMode (str): 'zero' or 'relative'


        Returns: A Graph instance
        """

        graphReader, logger = RegExpReader(piMode=primaryIOmode), None
        graphReader.parseGateNetlistFile(filePath, libraryPath=libraryPath)

        if logger is not None:
            logger.info("Reading graph...")

        graph, summaryString = Graph.fromReader(
            graphReader,
            sourceFileName=filePath.name,
            libraryPath=libraryPath,
            printSummaryTable=printSummaryTable,
        )

        if printSummaryTable:
            max_cols = pd.get_option("display.max_columns")
            pd.set_option("display.max_columns", None)
            tv = pd.DataFrame(
                summaryString,
                columns=["net", "type", "source_node", "target_nodes", "aliases"],
            )
            tv.set_index("net", inplace=True)
            print(tv)
            pd.set_option("display.max_columns", max_cols)

        if scoapPath is not None and scoapPath.exists():
            graph.addScoapData(scoapPath, primaryIOmode, verbose)
        elif verbose:
            print(f"WARNING: No SCOAP data provided for {filePath.name}")

        if switchingPath is not None and switchingPath.exists():
            graph.addSwitchingData(switchingPath, verbose)
        elif verbose:
            print(f"WARNING: No SWITCHING data provided for {filePath.name}")

        if faultPath is not None and faultPath.exists():
            graph.addFaultData(faultPath, primaryIOmode, verbose)
        elif verbose:
            print(f"WARNING: No FAULT data provided for {filePath.name}")

        depths = calcLogicDepth(graph, timeit=verbose, ffDepthMode=ffDepthMode)
        for n, d in depths.items():
            graph.nodes[n]["logicDepth"] = d

        return graph

    def nodeAtIdx(self, idx):
        return list(self.nodes.keys())[idx]

    def addScoapData(self, path: Path, piMode: PIMode, verbose=False):
        scoapData = DataHelpers.readSCOAP(path)
        if verbose:
            entries = tqdm.tqdm(
                scoapData.instances.items(), desc="Adding SCOAP to graph"
            )
        else:
            entries = scoapData.instances.items()
        printer = entries.write if verbose else print
        for eid, moduleEntries in entries:
            for entry in moduleEntries:
                for inst in entry.instances:
                    if inst.isOutput and inst.identifier is not None:
                        nId = nodeIdForPrimaryIO(
                            entry.instanceType, entry.identifier, piMode
                        )
                        # for edge in self.edges:
                        #     if edge[0] == NodePort(nName, pId):
                        #         # atpg values for output net apply to node attributes
                        #         # Handle differing output observability
                        #         if 'control0' in self.nodes[nName].keys():
                        #             for i, k in enumerate(['control0', 'control1', 'observe']):
                        #                 if self.nodes[nName][k] != inst.atpg.combinational[i]:
                        #                     msg = f'Conflicting ATPG values for node {nName}\n' \
                        #                           f'{self.nodes[nName]}, {inst.atpg.combinational}'
                        #                     raise Exception(msg)
                        try:
                            self.nodes[nId].update(
                                dict(
                                    control0=inst.atpg.combinational[0],
                                    control1=inst.atpg.combinational[1],
                                    observe=inst.atpg.combinational[2],
                                    seqControl0=inst.atpg.sequential[0],
                                    seqControl1=inst.atpg.sequential[1],
                                    propValObserve=inst.atpg.sequential[2],
                                    sensGatObserve=inst.atpg.sequential[3],
                                )
                            )
                        except KeyError:
                            if verbose:
                                printer(
                                    f"WARNING: No Node for SCOAP Entry {entry.identifier}"
                                )
                        break

        # Handle any cases where scoap values weren't added to nodes
        # ensures that feature vectors are the same length
        for node, attrs in self.nodes.items():
            if "control0" not in attrs.keys():
                raise Exception(f"SCOAP data not found for node: {node}")
                # self.nodes[node].update(dict(
                #     control0=np.iinfo(np.int32).min,
                #     control1=np.iinfo(np.int32).min,
                #     observe=-np.iinfo(np.int32).min
                # ))

    def addSwitchingData(self, path: Path, verbose=False):
        probs = DataHelpers.readSwitchingProbabilities(path)
        probs.set_index("net", inplace=True)

        if verbose:
            edges = tqdm.tqdm(self.edges.items(), desc="Switching probs")
        else:
            edges = self.edges.items()

        aliasedNets = []
        valKeys = [
            "switchingProb0_1",
            "switchingProb1_0",
            "staticProb",
            "toggleRate",
            "totalNetLoad",
            "switchPower",
            "switchingAttr",
        ]
        for edge, attrs in edges:
            netId = attrs.netId
            aliases = attrs.aliases
            try:
                vals = dict(
                    # Switching probability (0->1) = toggleRate * staticProb
                    # Switching probability (1->0) = toggleRate * (1 - staticProb)
                    # Switching probability (0->0) = (1 - toggleRate) * (1 - staticProb)
                    # Switching probability (1->1) = (1 - toggleRate) * staticProb
                    switchingProb0_1=probs.loc[netId].toggleRate
                    * probs.loc[netId].staticProb,
                    switchingProb1_0=probs.loc[netId].toggleRate
                    * (1.0 - probs.loc[netId].staticProb),
                    staticProb=probs.loc[netId].staticProb,
                    toggleRate=probs.loc[netId].toggleRate,
                    totalNetLoad=probs.loc[netId].totalNetLoad,
                    switchPower=probs.loc[netId].switchingPower,
                    switchingAttr=probs.loc[netId].attrs,
                )
                attrs.update(vals)
            except KeyError:
                aliasedNets.append(netId)

        for net in set(aliasedNets):
            for edge in self.edgeLookup[net]:
                attrs = self.edges[edge]
                if set(valKeys) not in set(attrs.keys()):
                    aliases = attrs["aliases"]
                    for alias in aliases:
                        didSet = False
                        for e in self.edgeLookup[alias]:
                            try:
                                self.edges[edge].update(
                                    {k: self.edges[e][k] for k in valKeys}
                                )
                                didSet = True
                            except:
                                pass
                            if (
                                didSet
                            ):  # only needs to find the first probs that were set
                                break  # breaks edgelookup
                        if didSet:
                            break  # breaks alias loop

    def addFaultData(self, path: Path, piMode, verbose=False):
        faultTable = DataHelpers.readFaultReport(path)
        faultCounts = faultTable.groupby(["pin", "stuckAt"]).faultType.value_counts()
        inNets = self.primaryInNets
        outNets = self.primaryOutNets
        counts = faultCounts.items()
        if verbose:
            counts = tqdm.tqdm(counts, total=faultCounts.shape[0], desc="Adding Faults")

        for (pin, sa, at), c in counts:
            pin = pin.strip(" ")
            if pin in inNets:
                nodeId, nodePin = nodeIdForPrimaryIO("pi", pin, piMode), pin
            elif pin in outNets:
                nodeId, nodePin = nodeIdForPrimaryIO("po", pin, piMode), pin
            else:
                try:
                    nodeId, nodePin = pin.split("/")
                except:
                    nodeId, nodePin = pin, pin

            self.nodes[nodeId].faultCounts[(nodePin, sa, at)] = c

        # for (source, target), attrs in tqdm.tqdm(self.edges.items(), desc="Faults"):
        #     nodeId = source.nodeId
        #     isPrimary = source.nodeId in self.inputNodeIds
        #     for sa in StuckAtFaultType:
        #         for at in ATPGFaultType:
        #             try:
        #                 self.nodes[nodeId].faultCounts[(netName, sa, at)] = faultCounts[(netName, sa, at)]
        #             except KeyError:
        #                 pass

    def _addNode(self, nodeId: NodeID, attributes: NodeAttributes = None):
        self.nodes[nodeId] = NodeAttributes() if attributes is None else attributes

    def addNode(
        self, node: Union[NodeEntry, NodePort], attributes: NodeAttributes = None
    ):
        """
        Add a node with optional attributes to the graph

        :param node: the node to add, can be of type NodeEntry or NodePort
        :param attributes: attributes for the node, of type NodeAttributes
        """
        if isinstance(node, NodeEntry):
            if node.identifier not in self.nodes.keys():
                if attributes is not None:
                    attributes.update(node.attributes)
                else:
                    attributes = node.attributes
                self._addNode(node.identifier, attributes)
        else:
            if node.nodeId not in self.nodes.keys():
                self._addNode(node.nodeId, attributes)

    def addEdge(
        self, source: NodePort, target: NodePort, attributes: EdgeAttributes = None
    ):
        if source.nodeId not in self.nodes.keys():
            self.addNode(source)
        if target.nodeId not in self.nodes.keys():
            self.addNode(target)

        if attributes is not None:
            attributes.update(sourcePort=source.port, targetPort=target.port)
        else:
            attributes = EdgeAttributes(
                nets=set(), sourcePort=source.port, targetPort=target.port
            )

        edge = (source, target)
        if edge in self.edges:
            self.edges[edge].nets.update(attributes.nets)
            attributes = self.edges[edge]
        else:
            self.edges[edge] = attributes

        for nId, nType in attributes.nets:
            if nId not in self.edgeLookup:
                self.edgeLookup[nId] = set()
            self.edgeLookup[nId].add((source, target))

    def to_json(self, filename: Path, unpicklable=True, overwrite=False):
        if filename.exists() and not overwrite:
            return

        import jsonpickle

        class EnumEncoder(jsonpickle.handlers.BaseHandler):
            def restore(self, obj):
                pass

            def flatten(self, obj: Enum, data):
                return obj.value

        if not unpicklable:
            jsonpickle.handlers.register(GraphType, EnumEncoder)
            jsonpickle.handlers.register(NodeType, EnumEncoder)
            jsonpickle.handlers.register(StuckAtFaultType, EnumEncoder)
            jsonpickle.handlers.register(ATPGFaultType, EnumEncoder)

        jsonSelf = jsonpickle.encode(self, unpicklable=unpicklable)

        filename.write_text(jsonSelf)

    def adjacencyMatrix(self) -> np.ndarray:
        return nx.to_numpy_matrix(self.toNetworkX())

    def toData(
        self,
        nodeFeatures: list,
        edgeFeatures: list = None,
        categoryFeatures: list = None,
        categoryEncoder: str = "binary",
    ) -> Data:
        nxGraph = self.toNetworkX()
        categoryFeatures = [] if categoryFeatures is None else categoryFeatures
        for i, (node, feat_dict) in enumerate(nxGraph.nodes(data=True)):
            tuples = [(key, value) for key, value in feat_dict.items()]
            for key, value in tuples:
                if hasattr(value, "toTorch"):
                    nxGraph.nodes[node][key] = value.toTorch(
                        categoryEncoding=categoryEncoder
                        if key in categoryFeatures
                        else None
                    )
                elif type(value) not in [int, str, float]:
                    nxGraph.nodes[node].pop(key)
        for i, (e1, e2, feat_dict) in enumerate(nxGraph.edges(data=True)):
            tuples = [(key, value) for key, value in feat_dict.items()]
            for key, value in tuples:
                if hasattr(value, "toTorch"):
                    nxGraph.edges[(e1, e2)][key] = value.toTorch(
                        categoryEncoding=categoryEncoder
                        if key in categoryFeatures
                        else None
                    )
                elif type(value) not in [int, str, float]:
                    nxGraph.edges[(e1, e2)].pop(key)

        data = pygeo_utils.from_networkx(
            nxGraph, group_node_attrs=nodeFeatures, group_edge_attrs=edgeFeatures
        )
        if data.x is not None:
            data.x = data.x.float()
        if data.edge_attr is not None:
            data.edge_attr = data.edge_attr.float()
        data.node_features = nodeFeatures
        data.edge_features = edgeFeatures
        return data

    def toNetworkX(self) -> nx.DiGraph:
        if self.type in [GraphType.directed, GraphType.directedAcyclic]:
            G = nx.DiGraph(directed=True)
        else:
            G = nx.Graph()

        for k, n in self.nodes.items():
            G.add_node(k, **n)

        for (sourceNode, targetNode), attrs in self.edges.items():
            if isinstance(sourceNode, NodePort):
                attrs.update(dict(sourcePort=sourceNode.port))
                sourceNode = sourceNode.nodeId
            if isinstance(targetNode, NodePort):
                attrs.update(dict(targetPort=targetNode.port))
                targetNode = targetNode.nodeId

            G.add_edge(sourceNode, targetNode, **attrs)

        return G

    # def toSpektralGraph(
    #         self,
    #         nodeFeatures: List[str],
    #         edgeFeatures: Optional[List[str]] = None,
    #         graphFeatures: Optional[List[str]] = None,
    #         calcLabelFn: Optional[GraphLabelerFunc] = None,
    #         labelMode='node'
    # ) -> sd.Graph:
    #     nodes = np.zeros((len(self.nodes), len(nodeFeatures)))
    #     adj = self.adjacencyMatrix()
    #     edges = None
    #
    #     if calcLabelFn is None:
    #         labels = None
    #     else:
    #         labelLen = len(self.nodes) if labelMode == 'node' else len(self.edges)
    #         labels = np.array([np.nan]*labelLen).reshape((labelLen, 1))
    #
    #     for i, (nodeId, attr) in enumerate(self.nodes.items()):
    #         vals = [attr[f].toTorch if isinstance(attr[f], GraphFeatureEnum) else attr[f] for f in nodeFeatures]
    #         featVec = np.array(vals)
    #         nodes[i, :] = featVec
    #         if labelMode == 'node' and calcLabelFn is not None:
    #             labels[i] = calcLabelFn(attr)
    #
    #     if edgeFeatures is not None:
    #         edges = np.zeros((len(self.edges), len(edgeFeatures)))
    #         for i, (_, _, attr) in enumerate(self.edges):
    #             vals = [attr[f].toTorch if isinstance(attr[f], GraphFeatureEnum) else attr[f] for f in
    #                     edgeFeatures]
    #             edges[i, :] = np.array(vals)
    #             if labelMode == 'edge' and calcLabelFn is not None:
    #                 labels[i] = calcLabelFn(attr)
    #
    #     if labelMode == 'graph' and calcLabelFn is not None:
    #         labels = calcLabelFn(self.features)
    #
    #     params = dict(
    #         x=nodes,
    #         a=adj,
    #         e=edges,
    #         y=labels
    #     )
    #
    #     if graphFeatures is not None:
    #         for feat in graphFeatures:
    #             params[feat] = self.features[feat]
    #
    #     return sd.Graph(**params)

    @staticmethod
    def drawGraph(
        G: nx.Graph,
        layout: GraphLayout.nx = GraphLayout.nx.multipartite,
        edgeLabelKey=None,
        nodeLabelKey=None,
        nodeColorKey=None,
        layoutArgs=None,
        title=None,
        nodeLabelIndexes=False,
        nodeAlpha=0.6,
        nodeSize=20,
        pltMargin=(0.1, 0.1),
        nodeLabelNudge=None,
        curvedPaths=True,
        figSize=(10, 7),
        nodeFilter=None,
        savePath: Path = None,
    ):
        """

        Args:
            G (networkx.Graph): Graph to draw
            layout (GraphLayout.nx): Selects layout
            edgeLabelKey (str): edge attribute key to use as a edge label
            nodeLabelKey (str): node attribute key to use as a node label
            nodeColorKey (str): node attribute key to use for deriving set of node colors (e.g. nodeType)
            layoutArgs (dict): arguments passed to the layout function, see NetworkX layout function documentation for details.
                NOTE: GraphLayout.nx.multipartite requires a 'subset_key' argument
            title (str): plot title
            nodeLabelIndexes (bool): whether or not to label nodes with their index in the graph
            nodeAlpha (float):
            nodeSize (int):
            pltMargin (Tuple[float, float]): plot margin (horizontal, vertical)
            nodeLabelNudge (Tuple[float, float]): shifts the node labels (xShift, yShift)
            curvedPaths (bool): draw edges as curved
            figSize (Tuple[int, int]): sets figure size
            nodeFilter (Callable): function to filter out nodes, takes in the graph and returns an array of nodes to keep
            savePath (Path): if set, will save the figure to the path and now show the resulting figure.

        Returns:

        """
        import matplotlib.pyplot as plt

        if layoutArgs is None:
            layoutArgs = dict()

        G_ = G.subgraph(nodeFilter(G)) if nodeFilter else G

        try:
            pos = layout.func(G_, **layoutArgs)
        except TypeError as e:
            raise e
        except:
            pos = nx.layout.kamada_kawai_layout(G_)

        if edgeLabelKey is not None:
            edgeLabels = {}
            for edge in G_.edges:
                edgeLabels[edge] = G_.edges[edge][edgeLabelKey]
        else:
            edgeLabels = None

        # get unique node_types
        types = set(nx.get_node_attributes(G_, nodeColorKey).values())
        mapping = dict(zip(sorted(types), count()))
        nodeLabels = {t: k.value for k, t in mapping.items()}

        nodes = G_.nodes()

        if len(mapping) > 0:
            colors = [mapping[G_.nodes[n][nodeColorKey]] for n in nodes]
        else:
            colors = None

        fig, ax = plt.subplots(1, 1, figsize=figSize)
        ax.set_axis_off()
        ax.margins(0)
        if curvedPaths:
            layout = {n: pos[n] for n in G_.nodes()}
            for edge in G_.edges:
                ax.annotate(
                    "",
                    xy=layout[edge[1]],
                    xycoords="data",
                    xytext=layout[edge[0]],
                    textcoords="data",
                    arrowprops=dict(
                        arrowstyle="-|>" if isinstance(G_, nx.DiGraph) else "-",
                        color="0",
                        alpha=0.4,
                        shrinkA=5,
                        shrinkB=5,
                        patchA=None,
                        patchB=None,
                        connectionstyle="arc3,rad=-0.2",
                    ),
                )
            # _ = nx.draw_networkx_edges(
            #     G,
            #     pos,
            #     arrowstyle='-|>' if isinstance(G, nx.DiGraph) else '-',
            #     alpha=0.4,
            #     connectionstyle='arc3,rad=-0.4',
            #     width=0.5
            # )
        else:
            _ = nx.draw_networkx_edges(
                G_,
                pos,
                arrowstyle="-|>" if isinstance(G_, nx.DiGraph) else "-",
                alpha=0.9,
                edge_color="0.2",
                width=0.5,
            )

        if edgeLabels is not None:
            nx.draw_networkx_edge_labels(
                G_, pos, edge_labels=edgeLabels, label_pos=0.75
            )

        nNodeLabels = len(nodeLabels)
        cmap = "Set1" if nNodeLabels <= 9 else "jet"
        pathCollection = nx.draw_networkx_nodes(
            G_,
            pos,
            nodelist=nodes,
            node_color=colors,
            node_size=nodeSize,
            alpha=nodeAlpha,
            cmap=plt.cm.get_cmap(cmap, nNodeLabels),
        )

        nodes = nx.draw_networkx_nodes(
            G,
            pos,
            nodelist=nodes,
            node_color=colors,
            node_size=nodeSize,
            alpha=nodeAlpha,
            cmap=plt.cm.get_cmap("jet", len(nodeLabels)),
        )

        if nodeLabelNudge is not None:
            nodeLabelPos = GraphLayout.nudge(pos, *nodeLabelNudge)
        else:
            nodeLabelPos = pos

        if nodeLabelKey is not None:
            try:
                nx.draw_networkx_labels(
                    G_,
                    nodeLabelPos,
                    labels={n: G_.nodes[n][nodeLabelKey] for n in G_.nodes},
                )
            except KeyError:
                print(f"Nodes do not have label key: {nodeLabelKey}")
        elif nodeLabelIndexes:
            nx.draw_networkx_labels(
                G_, nodeLabelPos, labels={n: i for i, n in enumerate(G_.nodes)}
            )
        else:
            nx.draw_networkx_labels(G_, nodeLabelPos, labels={})

        if len(types) > 0:
            formatter = plt.FuncFormatter(lambda val, loc: nodeLabels[loc])
            plt.colorbar(
                pathCollection,
                ticks=np.arange(0, len(types)),
                format=formatter,
                location="bottom",
                fraction=0.03,
                pad=0,
            )

        if title is not None:
            plt.title(title)

        plt.margins(*pltMargin)

        plt.tight_layout()
        if savePath is None:
            plt.show()
        else:
            savePath.parent.mkdir(parents=True, exist_ok=True)
            plt.savefig(savePath.as_posix())
            plt.close()

    def drawTreeDecomp(
        self,
        roots,
        saveDir: Path = None,
        curvedPaths=False,
        figsize=(20, 10),
        nodeLabelNudge=(0, 0.03),
        consider_leaf=_def_consider_leaf,
    ):
        if saveDir is not None:
            saveDir.mkdir(parents=True, exist_ok=True)

        G = self.toNetworkX()

        if not isinstance(roots, list):
            roots = [roots]

        for root, tree in tqdm.tqdm(
            getDAGTreesBFS(G, roots, consider_leaf=consider_leaf)
        ):
            subgraph = nx.subgraph_view(
                G,
                filter_node=lambda n: n in tree.nodes,
                # filter_edge=lambda u, v: (u == root or not consider_leaf(u, G.nodes[u])) and v != root,
            )

            # assert nx.is_directed_acyclic_graph(subgraph), f'Has cycles'

            for n in tree.nodes():
                subgraph.nodes[n]["depth"] = tree.nodes[n]["depth"]
                tree.nodes[n]["identifier"] = G.nodes[n]["identifier"]
                try:
                    tree.nodes[n]["nodeType"] = G.nodes[n]["nodeType"]
                except:
                    pass

            if len(tree) <= 1:
                print(f"{root}: {tree}")
            else:
                Graph.drawGraph(
                    subgraph,
                    title=f"{root} Subgraph",
                    layout=GraphLayout.nx.multipartite,
                    nodeColorKey="nodeType",
                    nodeLabelKey="identifier",
                    layoutArgs=dict(subset_key="logicDepth"),
                    curvedPaths=curvedPaths,
                    nodeLabelNudge=nodeLabelNudge,
                    figSize=figsize,
                    savePath=saveDir / f"{self.name}_{root}.pdf"
                    if saveDir is not None
                    else None,
                )
                Graph.drawGraph(
                    tree,
                    title=f"{root} BFS Tree",
                    nodeColorKey="nodeType",
                    nodeLabelKey="identifier",
                    nodeLabelIndexes=True,
                    layoutArgs=dict(subset_key="depth"),
                    curvedPaths=curvedPaths,
                    nodeLabelNudge=nodeLabelNudge,
                    figSize=figsize,
                    savePath=saveDir / f"{self.name}_{root}_tree.pdf"
                    if saveDir is not None
                    else None,
                )

    def draw(
        self,
        layout: GraphLayout.nx = GraphLayout.nx.multipartite,
        edgeLabelKey=None,  # 'netId',
        nodeLabelKey=None,  # 'identifier',
        nodeColorKey="nodeType",
        curvedPaths=False,
        layoutArgs=None,
        layerKey="logicDepth",
        savePath=None,
        ffSubtreeSources=None,
        **kwargs,
    ):
        """

        Args:
            layout (): see doc for Graph.drawGraph()
            edgeLabelKey (): see doc for Graph.drawGraph()
            nodeLabelKey (): see doc for Graph.drawGraph()
            nodeColorKey (): see doc for Graph.drawGraph()
            curvedPaths (): see doc for Graph.drawGraph()
            layoutArgs (): see doc for Graph.drawGraph()
            layerKey (): see doc for Graph.drawGraph()
            savePath (): see doc for Graph.drawGraph()
            ffSubtreeSources (): list of flip flop subtree roots to draw.
                Draws the subgraph for the nodes in that each of the trees separately.
            **kwargs (): forwards other arguments to Graph.drawGraph()

        Returns:

        """
        # TODO: use relative scan/ff
        layoutArgs = (
            dict(subset_key=layerKey)
            if layoutArgs is None and layout == GraphLayout.nx.multipartite
            else layoutArgs
        )

        if ffSubtreeSources is not None:
            node, tree = next(
                getDAGTreesDFS(
                    self.toNetworkX(),
                    ffSubtreeSources
                    if isinstance(ffSubtreeSources, list)
                    else [ffSubtreeSources],
                    consider_leaf=lambda n, a: a["nodeType"].isFF,
                )
            )

            Graph.drawGraph(
                tree,
                title=node,
                nodeColorKey="nodeType",
                nodeLabelKey="identifier",
                layoutArgs=dict(subset_key="depth"),
                curvedPaths=False,
                nodeLabelNudge=(0, 0.01),
                figSize=(30, 10),
                savePath=savePath,
                **kwargs,
            )
        else:
            Graph.drawGraph(
                self.toNetworkX(),
                layout=layout,
                edgeLabelKey=edgeLabelKey,
                nodeLabelKey=nodeLabelKey,
                nodeColorKey=nodeColorKey,
                layoutArgs=layoutArgs,
                curvedPaths=curvedPaths,
                savePath=savePath,
                **kwargs,
            )
