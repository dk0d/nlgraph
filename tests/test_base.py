# %%
import nlgraph as ng
from pathlib import Path
from nlgraph.graph import Graph

if Path.cwd().name == "tests":
    RESOURCES_DIR = Path("./resources").resolve()
else:
    RESOURCES_DIR = Path("./tests/resources").resolve()

NETLIST_DIR = RESOURCES_DIR / "netlists"


def test_parse():
    for vPath in NETLIST_DIR.glob("*.v"):
        if "PRESENT" not in vPath.name:
            continue
        graph = Graph.fromVerilog(
            filePath=vPath,
        )

        assert graph is not None, f"Failed to parse {vPath.name}"


test_parse()

print("Done!")
