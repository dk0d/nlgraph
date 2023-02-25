import nlgraph as ng
from pathlib import Path
from nlgraph.graph import Graph

RESOURCES_DIR = Path('./tests/resources').resolve()
NETLIST_DIR = RESOURCES_DIR / 'netlists'

def test_parse():
    vPath = NETLIST_DIR / 'netlist_b01.v'
    graph = Graph.fromVerilog(
        filePath=vPath
    )
    print('testing parsing')


