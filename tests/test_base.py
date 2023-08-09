# %%
import pytest
from pathlib import Path
from nlgraph.graph import Graph

if Path.cwd().name == "tests":
    RESOURCES_DIR = Path("./resources").resolve()
else:
    RESOURCES_DIR = Path("./tests/resources").resolve()

NETLIST_DIR = RESOURCES_DIR / "netlists"


@pytest.mark.parametrize(
    "filePath",
    [vPath.as_posix() for vPath in NETLIST_DIR.glob("*.v")],
)
def test_parse(filePath):
    graph = Graph.fromVerilog(
        filePath=Path(filePath),
    )
    assert graph is not None, f"Failed to parse {filePath.name}"
