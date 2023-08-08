from __future__ import annotations

import copy
import re
import string
from enum import Enum
from pathlib import Path

from typing import List, Optional


PathLike = str | Path


def makeNumerical(val: str):
    try:
        if "." in val:
            return float(val)
        return int(val)
    except:
        return val


def getListOfChildren(ctx, classType):
    return list(ctx.getChildren(lambda x: isinstance(x, classType)))


def getFirstChild(ctx, classType):
    try:
        return getListOfChildren(ctx, classType)[0]
    except:
        return None


class RegexConstants:
    BIAS_EXP = r"[10]'b[10]"

    # ['D', 'CLK', 'IN', 'INP', 'RSTB', 'S', 'CI'] added 'A' - 'P' for benchmark parsing
    PIN_INPUT_EXP = r"IN\d*|D\d*|INP\d*|RSTB\d*|S\d*|CLK\d*|[A-P]\d*|CI"

    # ['Q', 'QN', 'Z', 'ZN', 'CO'] added 'Y' for benchmark parsing
    PIN_OUTPUT_EXP = r"Q\d*|QN\d*|Z\d*|ZN\d*|Y\d*|CO"

    ADDER_INPUT_EXP = r"IN\d*|D\d*|INP\d*|RSTB\d*|CLK\d*|[A-P]\d*|CI"
    ADDER_OUTPUT_EXP = r"Q\d*|QN\d*|Z\d*|ZN\d*|Y\d*|CO|SO?\d*"

    ID_EXP = r"[\/\\\w\d\-_]+"
    ID_LIST = r"[\/\\\w\d\s\-,_]+"
    ID_BUS_EXP = r"[\/\\\[\]\w\d\-_]+"
    ID_BUS_EXP_LIST = r"[\/\\\[\]\w\d\s\-,_]+"
    RANGE = r"\s*\[(\d+\:\d+)\]"
    PORT_LIST = r"[\/\\\[\]\d\w\s,\(\)\._]+"

    NEWLINE = r"[\s\n]+"

    MODULE_EXP = r"module\s+(" + ID_EXP + r")\s*\((" + ID_LIST + r")\)\s*\;"
    INPUT_EXP = r"input(?:" + RANGE + r")?\s+(" + ID_BUS_EXP_LIST + r")\s*\;"
    OUTPUT_EXP = r"output(?:" + RANGE + r")?\s+(" + ID_BUS_EXP_LIST + r")\s*\;"
    WIRE_EXP = r"wire(?:" + RANGE + r")?\s+(" + ID_BUS_EXP_LIST + r")\s*\;"
    ASSIGN_EXP = r"assign\s+(" + ID_BUS_EXP + r")\s*=\s*(" + ID_BUS_EXP + r")\s*\;"
    ENTRY_EXP = (
        r"((?![module])"
        + ID_EXP
        + r")\s+("
        + ID_BUS_EXP
        + r")\s*\(\s*("
        + PORT_LIST
        + r")\s*\)\s*\;"
    )
    PORT_DECLARATION_EXP = r"\.([A-z]+\d*)\((.+)\)"


class InvalidLibraryType(Exception):
    pass


class LibraryType(Enum):
    gsc45_svt_3p0 = "gsclib45_svt_3p0"
    gsc180_svt_3p0 = "gsclib180_svt_3p0"
    saed90_typ_1p11 = "saed90_typ_1p11"
    leda_fpga = "leda_fpga"
    blackbox = "blackbox"

    def __repr__(self):
        return self.value

    def __str__(self):
        return self.value

    @property
    def file(self):
        if self in [
            LibraryType.gsc45_svt_3p0,
            LibraryType.gsc180_svt_3p0,
            LibraryType.saed90_typ_1p11,
            LibraryType.leda_fpga,
        ]:
            return f"{self.value}.v"
        return None

    @property
    def libDir(self):
        return Path(__file__).parent / "libraries"

    @property
    def libPath(self):
        return self.libDir / self.file

    @property
    def libName(self):
        return self.libPath.stem

    @classmethod
    def get(cls, x):
        for lt in cls:
            if re.search(lt.value, x) is not None or re.search(x, lt.value) is not None:
                return lt
        raise InvalidLibraryType(f"{x}")

    def inputpinSequence(self, num):
        if self in [LibraryType.gsc45_svt_3p0, LibraryType.gsc180_svt_3p0]:
            return string.ascii_uppercase[:num]
        elif self == LibraryType.saed90_typ_1p11:
            return [f"IN{i + 1}" for i in range(num)]


class Template(str, Enum):
    @classmethod
    def _folderName(cls):
        return "tcl_templates"

    @classmethod
    def _templatePath(cls):
        return (Path(__file__).parent / cls._folderName()).resolve()

    @classmethod
    def fromString(cls, string: str):
        for nType in cls:
            f = re.search(string, nType.value, re.IGNORECASE)
            if f is not None:
                return nType
        raise Exception(f"String not a valid node type: {string}")

    def __call__(self, value: str):
        return Template.fromString(value)

    @property
    def helperPath(self):
        return self._templatePath() / "helpers.tcl"

    @property
    def path(self):
        return self._templatePath() / f"{self.value}.tcl.template"


class NLGraphTemplate(Template):
    logicSynth = "logic_synth"
    calcScoap = "calc_scoap"
    logicDepth = "logic_depth"


def getTopModule(path: Path):
    if path is None:
        return None
    try:
        text = path.read_text()
        name = re.search(r"module\s+([_\/\\\w\d\-]+)\s*\(?", text).group(1)
    except FileNotFoundError:
        return None
    return name


# [design name]_[library name][technology node]_[lib voltage]_[lib version]_[version].v
class Benchmark:
    def paramDict(self, **additionalParams):
        params = dict(
            benchmark_id=self.identifier,
            benchmark_name=self.benchName,
            benchmark_directory=self.rootDir,
            top_module=self.topModuleName,
            library=self.library,
            version=self.version,
            output_directory=self.versionsDir,
        )

        # allows for overriding defaults
        params.update(**additionalParams)
        return params

    @staticmethod
    def parseLibraryName(name: str):
        parts: List[Optional[str]] = name.split("_")
        try:
            libnode = re.search(r"([A-Za-z]+)(\d+)", parts[0])
            parts[0] = libnode.group(1)
            parts.insert(1, libnode.group(2))
        except:
            parts.insert(1, "")
            parts[1] = None
        return parts

    @staticmethod
    def fromDesignPath(path: Path) -> Benchmark:
        filename = path.name
        if "." in filename:
            name = Path(filename).stem
        else:
            name = filename
        parts: List[Optional[str]] = name.split("_")
        libParts = Benchmark.parseLibraryName("_".join(parts[1:]))
        parts = parts[:1] + libParts
        keys = [
            "designName",
            "libraryName",
            "techNode",
            "libVoltage",
            "libVersion",
            "version",
        ]
        if len(parts) == 7:
            keys.append("modifier")
        pairs = zip(keys, parts)
        pairs = {k: v for k, v in pairs}
        pairs["rootDir"] = path.parent
        return Benchmark(**pairs)

    @property
    def vPath(self):
        return self._fullPath("v")

    @property
    def topModuleName(self):
        return getTopModule(self.vPath)

    @property
    def benchName(self):
        library = self.library
        if library is not None:
            return "_".join([self.designName, library])
        return self.designName

    @property
    def test_benchName(self):
        library = self.library
        if library is not None:
            return "_".join([self.designName, library, "expected"])
        return self.designName

    @property
    def library(self):
        if all(
            [
                c is not None
                for c in [
                    self.libraryName,
                    self.techNode,
                    self.libVoltage,
                    self.libVersion,
                ]
            ]
        ):
            return "_".join(
                [f"{self.libraryName}{self.techNode}", self.libVoltage, self.libVersion]
            )
        return None

    @property
    def libraryType(self):
        return LibraryType.get(f"{self.libraryName}{self.techNode}")

    def libPathWithRoot(self, root):
        return root / f"{self.library}.v" if self.library is not None else None

    @property
    def identifier(self):
        parts = [self.benchName]
        if self.version is not None:
            parts.append(self.version)
        return "_".join(parts)

    @property
    def versionsDir(self) -> Path:
        if self.rootDir is not None:
            dd = self.rootDir / self.benchName if self.version is None else self.rootDir
            if not dd.exists():
                dd.mkdir(parents=True)
            return dd
        return Path(self.benchName)

    def _dataFile(self, ext):
        name = f"{self.identifier}{ext}"
        if self.versionsDir is not None:
            return self.versionsDir / name
        return Path(name)

    @property
    def scoapPath(self) -> Path:
        return self._dataFile(".scoap")

    @property
    def faultPath(self) -> Path:
        return self._dataFile(".fault")

    @property
    def switchPath(self) -> Path:
        return self._dataFile(".switching")

    @property
    def graphPath(self):
        return self._dataFile(".pt")

    @property
    def versionsAvailable(self):
        versions = [
            re.search(f"{self.benchName}_(\w+)\.v", p.name).group(1)
            for p in self.versionsDir.glob(f"{self.benchName}_*.v")
        ]
        versions.sort()
        return versions

    def __repr__(self):
        return self.identifier

    def __str__(self):
        return self.identifier

    def _fullPath(self, ext):
        try:
            if self.version is None:
                return self.rootDir / f"{self.identifier}.{ext}"
            return self.versionsDir / f"{self.identifier}.{ext}"
        except:
            return None

    def __init__(
        self,
        designName,
        libraryName="saed",
        techNode="90",
        libVoltage="typ",
        libVersion="1p11",
        version=None,
        rootDir: Optional[Path] = None,
        **kwargs,
    ):
        if "library" in kwargs.keys():
            library = kwargs["library"]
            if library is not None:
                (
                    self.libraryName,
                    self.techNode,
                    self.libVoltage,
                    self.libVersion,
                ) = Benchmark.parseLibraryName(library)
            else:
                self.libraryName, self.techNode, self.libVoltage, self.libVersion = (
                    None,
                    None,
                    None,
                    None,
                )
        else:
            self.libraryName: str = libraryName
            self.techNode: str = techNode
            self.libVoltage: str = libVoltage
            self.libVersion: str = libVersion

        self.designName: str = designName
        self.clock: str = self.getBenchmarkClkRst(designName)["clock"]
        self.reset: str = self.getBenchmarkClkRst(designName)["reset"]
        self.version: Optional[str] = version
        self.rootDir: Path = (
            rootDir.expanduser().resolve() if rootDir is not None else None
        )

        if self.rootDir is not None and not self.vPath.exists():
            raise FileNotFoundError(f"Benchmark not found: {self.vPath}")

    def withVersion(self, version):
        newBench = copy.deepcopy(self)
        if self.version is None and version is not None:
            newBench.rootDir = self.versionsDir
        elif self.version is not None and version is None:
            newBench.rootDir = self.rootDir.parent

        newBench.version = version

        return newBench

    # TODO: Remove this hardcoded data
    def getBenchmarkClkRst(self, designName):
        data = {
            "aes128": {"clock": "clk", "reset": None},
            "aescipher": {"clock": "clock", "reset": "rst"},
            "b01": {"clock": "clock", "reset": "reset"},
            "b03": {"clock": "clock", "reset": "reset"},
            "b06": {"clock": "clock", "reset": "reset"},
            "b08": {"clock": "CLOCK", "reset": "RESET"},
            "b09": {"clock": "clock", "reset": "reset"},
            "b12": {"clock": "clock", "reset": "reset"},
            "b14": {"clock": "clock", "reset": "reset"},
            "b15": {"clock": "clock", "reset": "reset"},
            "b22": {"clock": "clock", "reset": "reset"},
            "cpu": {"clock": "clk_i", "reset": None},
            "darkriscv": {"clock": "clock", "reset": "RES"},
            "darksocv": {"clock": "XCLK", "reset": "XRES"},
            "divider": {"clock": "in", "reset": "reset"},
            "eth": {"clock": "wb_clk_i", "reset": "wb_rst_i"},
            "i2cmaster": {"clock": "clock", "reset": "wb_rst_i"},
            "mips16core": {"clock": "clk", "reset": "rst"},
            "oc8051": {"clock": "wb_clk_i", "reset": "wb_rst_i"},
            "ps2": {"clock": "wb_clk_i", "reset": "wb_rst_i"},
            "riscvcore": {"clock": "clk_i", "reset": "rst_i"},
            "top": {"clock": "clock", "reset": "rst"},
            "wbconmax": {"clock": "clock", "reset": "rst_i"},
            "yacc": {"clock": "clock", "reset": "Async_Reset"},
        }
        return data.get(designName, dict(clock="clock", reset="reset"))
