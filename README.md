# NLGraph

NeList Graph

Reads a verilog gate-level netlist into a `nlgraph.Graph` object.

The `Graph` object provides utilities for working with netlist graphs and machine learning using pytorch.

# TODOs

- [ ] pypi release
- [ ] Usage examples in readme

# Post Install PyTorch Dependencies

After installation, you can use `torchinstaller` (installed as a dependency to this project) to help install pytorch and torch-geometric dependencies if you'd like.
`torchinstaller` helps to automatically detect cuda versions and/or just to build the right install commands for pytorch, etc.
See [`torchinstaller`](https://github.com/dk0d/torchinstaller) for more details.

e.g.

Dry run install (no `-i` flag)

```bash
> torchinstall --pytorch --lightning --pyg -pyg-src
```

PyTorch and PyTorch-Lightning

```bash
> torchinstall --pytorch --lightning -i
```

PyTorch-Geometric

```bash
> torchinstall --pyg -i
torchinstall --pyg -pyg-src -i
torchinstall --pytorch --lightning --pyg -pyg-src -i
```

PyTorch-Geometric from source

```bash
> torchinstall --pyg -pyg-src -i
```

Install all

```bash
> torchinstall --pytorch --lightning --pyg -pyg-src -i
```
