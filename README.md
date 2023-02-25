# NLGraph

NeList Graph

Reads a verilog gate-level netlist into a `nlgraph.Graph` object.

The `Graph` object provides utilities for working with netlist graphs and machine learning using pytorch.

# TODOs

- [ ] pypi release
- [ ] pyproject.toml
- [ ] Usage examples in readme

# Environment Setup

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

### Notes

* Include SCOAP values/node attributes as a key-value pair in the `Graph.nodes` attribute
* The same for edges, have edge attributes be a key-value pair in the dictionary of the attribute tuple




