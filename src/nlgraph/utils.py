from __future__ import annotations

import concurrent.futures
import itertools
import random
import re
import string
import subprocess
import sys
from concurrent.futures import ProcessPoolExecutor
from enum import Enum
from pathlib import Path
from queue import Empty, Queue
from threading import Thread
from typing import Union, List, Callable, Optional

import category_encoders as ce
import networkx as nx
import numpy as np
import pandas as pd
import tqdm

# Insertion Helpers
from .common import Template, Benchmark


def multiprocess(
    func,
    argsList,
    ProcessPool=ProcessPoolExecutor,  # or ThreadPoolExecutor
    onResult: Optional[Callable] = None,
    maxProc=400,
    desc="Processing",
    showProg=True,
):
    """

    Args:
        func ():
        argsList ():
        ProcessPool ():
        onResult (): Callback when result collected, takes in result object and the progress bar for updating post-fix or other operations.
        maxProc ():
        desc ():
        showProg ():

    Returns:

    """
    iterArgs = iter(argsList)
    if showProg:
        prog = tqdm.tqdm(total=len(argsList), desc=desc)
    else:
        prog = None
    with ProcessPool() as pool:
        futures = {
            pool.submit(func, **a)
            for a in itertools.islice(iterArgs, maxProc)
        }
        while futures:
            done, futures = concurrent.futures.wait(
                futures, return_when=concurrent.futures.FIRST_COMPLETED
            )
            for f in done:
                res = f.result()
                if onResult is not None:
                    onResult(res, prog)
                if prog is not None:
                    prog.update()

            for a in itertools.islice(iterArgs, len(done)):
                futures.add(pool.submit(func, **a))


# Insertion Helpers
def getFanInMask(
    graph: nx.DiGraph,
    nodeIdx: int
):
    """
        Returns a mask for the nodes where
        True == non-masked (included) -- i.e. IS a fan-in node
        False == masked (excluded) -- i.e. is NOT a fan-in node


    Args:
        graph (nx.DiGraph):
        nodeIdx (int): index of node to calculate fan in for

    Returns
        node mask (bool)
    """
    fanIn = set(graph.predecessors(nodeIdx))
    workingFanIn = set(fanIn)
    while len(workingFanIn) > 0:
        f = workingFanIn.pop()
        fPreds = set(graph.predecessors(f))
        if len(fPreds) > 0:
            fanIn.update(fPreds)
            workingFanIn.update(fPreds)

    mask = np.zeros((graph.number_of_nodes(),)).astype(int)
    fanIn = np.array(list(fanIn))
    mask[fanIn] = True
    return mask


ENCODERS = {
    'backwardDifference': ce.backward_difference.BackwardDifferenceEncoder,
    'basen': ce.basen.BaseNEncoder,
    'binary': ce.binary.BinaryEncoder,
    'cat_boost': ce.cat_boost.CatBoostEncoder,
    'hashing': ce.hashing.HashingEncoder,
    'helmert': ce.helmert.HelmertEncoder,
    'james_stein': ce.james_stein.JamesSteinEncoder,
    'one_hot': ce.one_hot.OneHotEncoder,
    'leave_one_out': ce.leave_one_out.LeaveOneOutEncoder,
    'm_estimate': ce.m_estimate.MEstimateEncoder,
    'ordinal': ce.ordinal.OrdinalEncoder,
    'polynomial': ce.polynomial.PolynomialEncoder,
    'sum_coding': ce.sum_coding.SumEncoder,
    'target_encoder': ce.target_encoder.TargetEncoder,
    'woe': ce.woe.WOEEncoder
}


class NLGraphEnum(Enum):

    @classmethod
    def fromString(cls, s: str):
        for nType in cls:
            f = re.search(nType.regex, s, re.IGNORECASE)
            if f is not None:
                return nType
        raise Exception(f'String not a valid node type: {s}')

    def __repr__(self):
        return self.value

    def __str__(self):
        return self.value

    def __call__(self, t):
        if isinstance(t, str):
            return NLGraphEnum.fromString(t)
        elif isinstance(t, int):
            for i, nt in enumerate(self.__class__):
                if t == i:
                    return nt
        else:
            raise Exception(f'Invalid node type value: {t}')

    def __new__(cls, value, regex=None):
        obj = type(value).__new__(cls, [value])
        obj._value_ = value
        obj.idx = len(cls.__members__)
        obj.regex = regex
        return obj

    def toTorch(self, categoryEncoding=None, members=None, **kwargs) -> Union[int, np.ndarray]:
        """

        Args:
            members (list): subset of class members to use for encoding
            categoryEncoding (str): one of ENCODERS keys: backwardDifference, basen, binary, cat_boost, hashing, helmert, james_stein,
                                one_hot, leave_one_out, m_estimate, ordinal, polynomial, sum_coding, target_encoder, woe
        Returns:

        """
        if members is None:
            members = self.__class__

        try:
            encoder = ENCODERS[categoryEncoding](cols=['members'])
        except:
            encoder = None

        if encoder is not None:
            g = encoder.fit(pd.DataFrame([{'members': m} for m in members]))
            df = g.transform(pd.DataFrame([{'members': t, 'type': t} for t in members]).set_index('type'))
            lookup = {k: np.array(list(v.values())) for k, v in df.to_dict(orient='index').items()}

            return lookup[self]

        return self.idx


class UnexpectedEndOfStream(Exception):
    pass


class StreamReader:

    @property
    def empty(self):
        return self._q.empty()

    def __init__(self, stream):
        assert stream is not None, f'Stream is None'
        self._s = stream
        self._q = Queue()

        self._t = Thread(
            target=self._populateQueue,
            args=()
        )
        self._t.daemon = True
        self._t.start()  # start collecting lines from the stream

    def _populateQueue(self):
        """
        collect lines from 'stream' and put them in 'queue'
        """
        try:
            while True:
                line = self._s.readline()
                if line:
                    self._q.put(line)
                else:
                    break
                    # raise UnexpectedEndOfStream
        finally:
            self._s.close()

    def readline(self):
        try:
            return self._q.get()
        except Empty:
            return None


def runProcess(
    args: list,
    logPath: Path = None,
    printOutput=False,
    logDidStart=None,
    logDidEnd=None,
    suppress=False,
    logAppend=True,
):
    """
    See subprocess.Popen for args structure

    Args:
        args (): Take an list of command elements
            e.g. Popen(["/usr/bin/git", "commit", "-m", "Fixes a bug."])
        logPath (): Path to save log of outputs
        # progress (): tqdm progress bar
        printOutput ():
        logDidStart ():
        logDidEnd ():
        suppress ():
        logAppend (bool):

    Returns:

    """
    printer = tqdm.tqdm.write
    args = [a.as_posix() if isinstance(a, Path) else a for a in args]

    if logPath is not None:
        logPath.parent.mkdir(parents=True, exist_ok=True)

    openMode = 'a' if logAppend else 'w'
    logFile = logPath.open(openMode) if logPath is not None else None

    # spinner = itertools.cycle('|/-\\')
    spinner = itertools.cycle("⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏")

    if not suppress:
        progress = tqdm.tqdm(desc='Running :', leave=False, bar_format='{desc} {elapsed}')
    else:
        progress = None

    if logDidStart is not None:
        logDidStart(logFile)

    killProcess = False
    extendedErrorInfo = False
    outputs = {}
    outputKey = None

    rc, errors, outputs = None, [], {}

    try:
        with subprocess.Popen(
                args,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
        ) as proc:
            while True:
                line = proc.stdout.readline()
                if proc.poll() is not None:
                    break
                # for line in iter(process.stdout.readline, b''):

                if progress is not None:
                    progress.set_description_str(f'Running {next(spinner)}')

                if not line:
                    continue

                text = str(line, encoding='utf-8')

                if logFile is not None:
                    # if error_line is not None:
                    #     logFile.write(error_line)
                    logFile.write(text)

                testText = text.lower()
                if re.search(r'^\s*puts', testText) is None:
                    if extendedErrorInfo or (
                            text[0] != "#" and 'error' in text.lower() and '0 errors' not in text.lower()):
                        if '\t' in text or extendedErrorInfo:
                            errors[-1][-1] += f'\t\t{text}'
                        else:
                            try:
                                code = re.search(r'\.\s+\(([\w\d\-]+)\)', text).group(1)
                            except:
                                code = "n/a"
                            errors.append([code, text])

                    if re.search(r'^\s*extended error info:', testText) is not None:
                        extendedErrorInfo = True
                    elif re.search(r"^[\s\t]*-- end extended error info", testText) is not None:
                        killProcess = True
                    elif re.search('__OUTPUT_(\w+)__', text) is not None:
                        outputKey = re.search('__OUTPUT_(\w+)__', text).group(1)
                        outputs[outputKey] = ""
                    elif outputKey is not None:
                        outputs[outputKey] += text
                    elif '__END_OUTPUT__' in text:
                        outputKey = None

                if printOutput:
                    printer(text, end='')
                    if killProcess:
                        printer(f' *** Killing Process *** ')

                if killProcess:
                    proc.kill()
                    break
            rc = proc.poll()
            rc = int(bool(rc) or killProcess)
    except Exception as e:
        printer("ERROR {} while running {}".format(sys.exc_info()[1], args))
    finally:
        if logFile is not None:
            if logDidEnd is not None:
                logDidEnd(logFile)
            logFile.close()
    return rc, errors, outputs


def tclParamSub(template: Union[Path, str], **params):
    # Read template
    _t = template.read_text() if isinstance(template, Path) else template

    removedComments = re.sub(r'(?m)^ *#.*\n?', '', _t)

    # Check key matches
    foundKeys = {
        m.group(1).strip('_'): m.group(2).strip('_') if m.group(2) is not None else None
        for m in re.finditer('\s*[^#+]\s*__(\w+)(?:\|([\w\d\./]+))?__', removedComments)
    }

    settingKeys = set([k.upper() for k in params.keys()])

    # find keys that are not defined and do not have default values
    diffKeys = [k for k in set(foundKeys).difference(settingKeys) if foundKeys[k] is None]

    if len(diffKeys) > 0:
        raise Exception(
            f'Missing Required TCL Template {template if isinstance(template, Path) else ""} Keys: {diffKeys}'
        )

    # Validate Path values
    params = {k: f'{v}' if isinstance(v, Path) else v for k, v in params.items()}

    for k, v in params.items():
        try:
            hasDefault = foundKeys[k.upper()] is not None
        except:
            continue
        repKey = f'__{k.upper()}__'
        if v is not None:
            if isinstance(v, str):
                value = f'"{v}"'
            elif isinstance(v, list):
                value = '{ ' + " ".join([f'{i}' for i in v]) + ' }'
            else:
                value = f'{v}'
        elif hasDefault:  # load found default value if none provided
            value = f'{foundKeys[k.upper()]}'
            try:
                _ = float(value)
                repKey = f'__{k.upper()}\|{foundKeys[k.upper()]}__'.replace('.', '\.')
            except:
                value = f'"{value}"'
                repKey = f'__{k.upper()}\|{foundKeys[k.upper()]}__'
        else:
            value = '""'
        _t = re.sub(repKey, value, _t)
    return _t


def nameGen(length):
    def _makeSeq():
        while True:
            yield ''.join(random.choices(string.ascii_letters + string.digits + '_', k=length))

    return _makeSeq()


class TCLTemplateException(Exception):
    def __init__(self, rc, errors, msg):
        super().__init__(msg)
        self.rc = rc
        self.errors = errors


def runTclTemplateOnBench(
    template: Union[Template, str],
    benchmark: Benchmark,
    command: str = None,
    logPath: Path = None,
    printOutput=False,
    **params,
):
    runTclTemplate(
        template,
        command,
        logPath,
        printOutput,
        **benchmark.paramDict(**params)
    )


def runTclTemplate(
    template: Template,
    command: str = None,
    logPath: Path = None,
    printOutput=False,
    **params,
):
    """
    Args:
        template (str):
        command (str):
        logPath (Path):
        printOutput (bool):
        **params (): Params passed to TCL template

    """

    if not template.path.exists():
        raise FileNotFoundError(template.path)

    loadedTemplate = tclParamSub(template.path.read_text(), **params)

    if command is None:
        try:
            command = re.search(r"\#\s*command:\s*(\w+)\s*", loadedTemplate).group(1).strip(' \n')
        except:
            raise TCLTemplateException(
                rc=1, errors=[],
                msg=f'Command must be specified in template or in function call for template: {template}'
            )

    helpersPath = template.helperPath
    if helpersPath.exists():
        loadedTemplate = f'{helpersPath.read_text()}\n{loadedTemplate}'

    procArgs = [command]
    if command == 'tmax':
        procArgs.append('-shell')
    elif command == 'dc_shell':
        procArgs.append('-f')
    else:
        raise Exception(f'Unsupported command: {command}')

    namer = nameGen(10)
    name = next(namer)
    tmpDir = Path('/tmp').resolve()
    if not tmpDir.exists():
        tmpDir.mkdir(parents=True)
    tclFile = tmpDir / f'tmp_{name}.tcl'
    while tclFile.exists():
        name = next(namer)
        tclFile = tmpDir / f'tmp_{name}.tcl'
    tclFile.write_text(loadedTemplate)

    procArgs.append(tclFile.as_posix())
    printer = tqdm.tqdm.write
    outputs = None
    try:
        printer('\n************************************************************************************************')
        printer(f'{"Command":<27}: {command} {template}')
        printer(f'{"Params":<27}: {params}')
        printer(f'{"Log Path":<27}: {logPath}')
        rc, errors, outputs = runProcess(procArgs, logPath=logPath, printOutput=printOutput)
        tclFile.unlink()
        printer(f'{"Return Status":<27}: {"COMPLETED" if rc == 0 else "FAILED"}')
        if errors is not None and len(errors) > 0:
            printer(f'{len(errors)} errors found')
            printer('------------------------------------------------')
            printer(f'{"CODE":<12} ERROR')
            for code, err in errors:
                printer(f'{code:<12} {err}', end='')
        printer('************************************************************************************************\n')
        if rc != 0:
            raise TCLTemplateException(rc=rc, errors=errors, msg='Template error killed process')
    finally:
        if tclFile.exists():
            tclFile.unlink()
    return outputs


def getFilesWithFilter(
    path: Path,
    design_name: str = None,
    lib_name: str = None,
    tech_node: str = None,
    lib_voltage: str = None,
    lib_version: str = None,
    version: str = None,
    modifier: str = None,
    fileExt: Union[str, List[str]] = None,
    recursive=False
) -> [Path]:
    globString = ""

    if design_name is not None:
        globString += f'{design_name}'
    if lib_name is not None:
        globString += f'_{lib_name}'
    if tech_node is not None:
        globString += f'{tech_node}'
    if lib_voltage is not None:
        globString += f'_{lib_voltage}'
    if lib_version is not None:
        globString += f'_{lib_version}'
    if version is not None:
        globString += f'_{version}'
    if modifier is not None:
        globString += f'_{modifier}'

    if recursive:
        globFunc = path.rglob
    else:
        globFunc = path.glob

    if isinstance(fileExt, str):
        exts = [fileExt]
    else:
        exts = fileExt

    files = []
    if exts is None:
        assert len(globString) > 0, f'At least one filter parameter must be set'
        files = list(globFunc(f"*{globString}*"))
    else:
        for ext in exts:
            ext = ext.strip(".")
            fs = f"*.{ext}" if len(globString) == 0 else f"*{globString}*{f'.{ext}'}"
            files.extend(list(globFunc(fs)))
    files.sort()
    return files


def getBenchmarksWithFilter(path: Path, **kwargs) -> [Benchmark]:
    files = getFilesWithFilter(path=path, **kwargs)
    return [Benchmark.fromDesignPath(p) for p in files]
