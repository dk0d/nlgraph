import re
import time
from collections import OrderedDict
from pathlib import Path
from typing import Optional
import tqdm

# from .parse.ScoapLexer import ScoapLexer
# from .parse.ScoapListener import ScoapListener
# from .parse.ScoapParser import ScoapParser


class InstanceEntry:

    @property
    def isOutput(self) -> bool:
        try:
            return self.iType.lower() in ['o', 'output']
        except AttributeError:
            return False

    @property
    def isInput(self) -> bool:
        try:
            return self.iType.lower() in ['i', 'input']
        except AttributeError:
            return False

    def __init__(self, identifier=None, iType=None, atpg=None, connection=None, bracketId=None):
        self.identifier = identifier
        self.iType = iType
        self.atpg: Optional[ATPGEntry] = atpg
        self.connection = connection
        self.bracketId = bracketId

    # @staticmethod
    # def fromCtx(
    #     ctx: Union[ScoapParser.Instance_input_entryContext,
    #                ScoapParser.Instance_output_entryContext,
    #                ScoapParser.Alt_entryContext,
    #                ScoapParser.Terminal_connection_statementContext]
    # ):
    #     try:
    #         identifier = getFirstChild(ctx, ScoapParser.IdentifierContext).getText()
    #     except:
    #         identifier = None
    #
    #     try:
    #         atpgs = getFirstChild(ctx, ScoapParser.Atpg_statementContext)
    #         atpg = [at.getText().strip('()') for at in atpgs.children[1:3]]
    #         atpg = ATPGEntry(combinational=atpg[0].split('-'), sequential=atpg[1].split('-'))
    #     except:
    #         atpg = None
    #
    #     try:
    #         connection = getFirstChild(ctx, ScoapParser.Connection_statementContext).getText().split('-')
    #     except:
    #         connection = None
    #
    #     try:
    #         bracket = getFirstChild(ctx, ScoapParser.Bracketed_identifierContext).getText()
    #     except:
    #         bracket = None
    #
    #     inst = InstanceEntry(identifier=identifier,
    #                          atpg=atpg,
    #                          connection=connection,
    #                          bracketId=bracket)
    #     if isinstance(ctx, ScoapParser.Instance_input_entryContext):
    #         inst.iType = 'input'
    #     elif isinstance(ctx, ScoapParser.Instance_output_entryContext):
    #         inst.iType = 'output'
    #     elif isinstance(ctx, ScoapParser.Alt_entryContext):
    #         inst.iType = 'alt'
    #     elif isinstance(ctx, ScoapParser.Terminal_connection_statementContext):
    #         inst.iType = 'connection'
    #     else:
    #         raise Exception(f'Unsupported context {ctx}')
    #
    #     return inst


class ATPGEntry:
    """
    Combinational ATPG, shown in the form of [A, B, C]. The fields indicate the minimum number of:

    - A = PIs and scan cells needed to place a 0 at the pin.
    - B = PIs and scan cells needed to place a 1 at the pin.
    - C = PIs and scan cells needed to observe the value on the pin.

    Sequential ATPG, shown in the form of [A, B, C, D]. These fields indicate the minimum scan depth needed to:
    - A = place a 0 at the pin.
    - B = place a 1 at the pin.
    - C = to propagate the value to an observe point.
    - D = to sensitize the gate to an observe point.

    > An asterisk "*" indicates the value exceeds the 254 limit the program can track.
    """

    def __init__(self, combinational, sequential):

        if isinstance(combinational[0], str):
            self.combinational = [self._makeInt(i) for i in combinational]
        else:
            self.combinational = combinational

        if isinstance(sequential[0], str):
            self.sequential = [self._makeInt(i) for i in sequential]
        else:
            self.sequential = sequential

    def _makeInt(self, val):
        try:
            return int(val)
        except:
            return -1


class ModuleEntry:

    @staticmethod
    def fromStrings(strings: [str]):
        statement = ModuleEntry()
        for s in strings:
            tqdm.tqdm.write(s)
        return statement

    def flatten(self, t):
        return [item for sublist in t for item in sublist]

    # @staticmethod
    # def fromCtx(ctx):
    #     entry = ModuleEntry()
    #     entry.identifier = ctx.getChild(0).getChild(0).getText()
    #     entry.instanceId = ctx.getChild(0).getChild(1).getText().replace('(', '').replace(')', '')
    #     entry.instanceType = ctx.getChild(0).getChild(2).getText()
    #     entry.moduleName = ctx.getChild(0).getChild(3).getText().replace('(', '').replace(')', '')
    #     for x in ctx.getChild(1).children:
    #         inst = InstanceEntry.fromCtx(x)
    #         entry.instances.append(inst)
    #     return entry

    def __init__(self, **kwargs):
        self.identifier = kwargs.get('identifier', None)
        self.instanceId = kwargs.get('instanceId', None)
        self.instanceType = kwargs.get('instanceType', None)
        self.moduleName = kwargs.get('moduleName', None)
        self.contextIdx = kwargs.get('contextIdx', None)
        self.instances: [InstanceEntry] = kwargs.get('instances', [])


class ContextStatement:

    # @staticmethod
    # def fromCtx(ctx):
    #     assigns = [
    #         a.getText().split('=') for a in
    #         getListOfChildren(ctx, ScoapParser.Assignment_statementContext)
    #     ]
    #     assigns = {k: makeNumerical(v) for k, v in assigns}
    #     groupedAssignments = getListOfChildren(ctx, ScoapParser.Group_identifier_assignmentContext)
    #     for ga in groupedAssignments:
    #         identifier = getListOfChildren(ga, ScoapParser.IdentifierContext)[0]
    #         assignments = [
    #             ga.getText().strip(',').split('=') for ga in
    #             getListOfChildren(ga, ScoapParser.Group_assignmentContext)
    #         ]
    #         for i, a in enumerate(assignments):
    #             if len(a) > 1:
    #                 assignments[i] = (a[0], makeNumerical(a[1]))
    #             else:
    #                 assignments[i] = makeNumerical(a[0])
    #         assigns[identifier.getText()] = assignments
    #     return ContextStatement(**assigns)

    def __init__(self, identifier=None, **kwargs):
        self.identifier = identifier
        self.data: dict = dict(**kwargs)
#
#
# class ScoaptoIndex(ScoapListener):
#
#     def __init__(self):
#         self.data = ScoapData()
#
#     def enterInstance_statement(self, ctx):
#         self.data.addInstance(ModuleEntry.fromCtx(ctx))
#
#     def enterPi_usage_statement(self, ctx):
#         self.data.addContextStatement(ContextStatement.fromCtx(ctx))
#
#     def enterPo_usage_statement(self, ctx):
#         self.data.addContextStatement(ContextStatement.fromCtx(ctx))


def searchVals(regExp, text, groupKeys):
    def _getGroup(_m, _i):
        try:
            return _m.group(_i)
        except:
            return None

    m = re.search(regExp, text)
    if m is None:
        return None
    groupVals = [_getGroup(m, i) for i in range(1, len(groupKeys) + 1)]
    return {k: v if v is None else t(v) for (k, t), v in zip(groupKeys, groupVals)}


def findAllVals(regExp, text):
    vs = re.findall(regExp, text)
    try:
        out = {}
        for k, v in vs:
            try:
                if '.' in v:
                    out[k] = float(v)
                else:
                    out[k] = int(v)
            except:
                out[k] = v
        return out
    except:
        return None


def combineConnection(_values):
    connection = [f'{_values["conn-id"]}']
    if _values['conn-moduleName'] is not None:
        connection.append(f'{_values["conn-moduleName"]}')
    return connection


class ScoapData:
    """
    Encapsulates SCOAP data from Synopsis output


    """

    @staticmethod
    def fromPath(path: Path, antlr=False):
        # if antlr:
        #     from .common import parsePipeline
        #     indexer, logger = parsePipeline(path, ScoapLexer, ScoapParser, ScoaptoIndex)
        #     return indexer.data
        # else:
        return ScoapData._fromPath(path)

    @staticmethod
    def _fromPath(path: Path, verbose=False):

        text = path.read_text()
        tic = time.time()

        sdata = OrderedDict()
        contexts = []

        ID_BRACKETED = r'[\/\\\[\]\w\d-]+'

        MODULE_EXP = r'(' + ID_BRACKETED + ')?\s+\((\d+)\)\s+(\w+)\s+\((' + ID_BRACKETED + ')\)'
        INSTANCE_EXP = r'(\!?---)?\s+(' + ID_BRACKETED + ')\s+(I|O)\s+\(([\d\*-]+)\s([\d\*-]+)\)(?:\s+(' + ID_BRACKETED + ')-)?(' + ID_BRACKETED + ')?'
        INSTANCE_EXP2 = r'(\d+)?-(' + ID_BRACKETED + ')?\s*(?:\.\.\.)?'
        INSTANCE_PWI = r'\!---\s+((?:PW)?I|(?:PW)?O)\s+\(\)\s+\((.+)\)'
        INSTANCE_PP = r''
        USAGE_EXP = r'(\w+)\s+usage:\s+(?:scan_state=(\d+)\s*)?(?:scanin\((\d+)\)\s*)?(?:scanout\((\d+)\)\s*)?(?:clock\((.+)\))?'
        SCAN_BEHAVIOR_EXP = r'scan_behavior:\s+MASTER\((.+)\)(.+)'

        currentModule = None
        currentContext = None
        lines = text.splitlines()
        if verbose:
            lines = tqdm.tqdm(lines, desc=f"Reading SCOAP {path.name}")

        for i, line in enumerate(lines):
            values = searchVals(MODULE_EXP, line, [
                ('identifier', str),
                ('instanceId', str),
                ('instanceType', str),
                ('moduleName', str)
            ])
            if values is not None:
                values.update(contextIdx=len(contexts))
                entry = ModuleEntry(**values)
                currentModule = entry
                if entry.identifier not in sdata.keys():
                    sdata[entry.identifier] = []
                sdata[entry.identifier].append(entry)
                continue

            values = searchVals(INSTANCE_EXP, line, [
                ('dashes', str),
                ('identifier', str),
                ('iType', str),
                ('atpg-com', lambda x: x.split('-')),
                ('atpg-seq', lambda x: x.split('-')),
                ('conn-id', str),
                ('conn-moduleName', str),
            ])
            if values is not None:
                try:
                    _ = values.pop('dashes')
                    atpg = ATPGEntry(
                        combinational=values.pop('atpg-com'),
                        sequential=values.pop('atpg-seq')
                    )
                    connection = combineConnection(values)
                    instance = InstanceEntry(
                        identifier=values['identifier'],
                        iType=values['iType'],
                        connection=connection,
                        atpg=atpg,
                    )
                    currentModule.instances.append(instance)
                except:
                    pass
                finally:
                    continue

            values = searchVals(INSTANCE_EXP2, line, [
                ('conn-id', str),
                ('conn-moduleName', str),
            ])
            if values is not None:
                try:
                    instance = InstanceEntry(connection=combineConnection(values))
                    currentModule.instances.append(instance)
                except:
                    pass
                finally:
                    continue

            values = searchVals(USAGE_EXP, line, [
                ('identifier', str),
                ('scan_state', str),
                ('scan_in', str),
                ('scan_out', str),
                ('clock', lambda x: [tuple(t.split('=')) if '=' in t else t for t in x.split(',')])
            ])
            if values is not None:
                # context = ContextStatement(identifier = None,
                # )
                currentContext = values
                contexts.append(values)
                continue

            values = searchVals(SCAN_BEHAVIOR_EXP, line, [('master', str), ('temp', str)])
            if values is not None:
                vs = {
                    'identifier': 'scan_behavior',
                    'master': values['master']
                }
                props = findAllVals(r'([\w\d_]+)=([\w\d_]+)', values['temp'])
                vs.update(**props)
                contexts.append(vs)
                continue

            raise Exception(f'Unable to parse line: {i + 1}, {line}')

        data = ScoapData(
            instances=sdata,
            contextStatements=[ContextStatement(**s) for s in contexts]
        )
        # prog.write(f'SCOAP Parse Elapsed: {time.time() - tic} s')
        return data

    def __init__(
        self,
        instances=None,
        contextStatements=None,
    ):
        if contextStatements is None:
            contextStatements = []
        if instances is None:
            instances = {}
        self.instances = instances
        self.contextStatements = contextStatements
        self._activeContextIdx = None

    def addContextStatement(self, statement):
        self.contextStatements.append(statement)
        self._activeContextIdx = len(self.contextStatements) - 1

    def addInstance(self, instance):
        instance.contextIdx = self._activeContextIdx
        if instance.identifier in self.instances.keys():
            self.instances[instance.identifier].append(instance)
        else:
            self.instances[instance.identifier] = [instance]
