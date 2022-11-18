# NLGraph
NeList Graph

Reads a verilog gate-level netlist into a `nlgraph.Graph` object

# Environment Setup

**TODO**: pypi release
**TODO**: pyproject.toml

**NOTE**
You can run the `envsetup.sh` script to create 
a conda environment and install all `nlgraph` dependencies

The script takes 4 optional parameters
```bash
$ sh envsetup.sh [ENVIRONMENT_NAME] [PYTHON_VERSION] [PYTORCH_VERSION] [CUDA_VERSION]
```

The default script values are: 
```bash
$ sh envsetup.sh nlgraph 3.9 1.13
```
`CUDA_VERSION` is blank by default and the script checks to see what cuda version is
available based on calling `nvidia-smi`.


# Usage

> [!TODO]

### Notes
* Include SCOAP values/node attributes as a key-value pair in the `Graph.nodes` attribute
* The same for edges, have edge attributes be a key-value pair in the dictionary of the attribute tuple




