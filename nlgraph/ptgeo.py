#  Copyright (c) University of Florida 2021.
#
#  Author: Daniel Capecci
#
#  This file is a part of stamp.
#
#  stamp is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.

import numpy as np
import torch

from torch_geometric.data import Data
from torch_geometric.utils import add_remaining_self_loops, to_networkx
from torch_geometric.utils.num_nodes import maybe_num_nodes
from torch_sparse import SparseTensor

from . import graph as ng
from .data import trainValTestSplit
from .utils import getFanInMask


def to_undirected_no_sort(edge_index, num_nodes=None):
    r"""Converts the graph given by :attr:`edge_index` to an undirected graph,
    so that :math:`(j,i) \in \mathcal{E}` for every edge :math:`(i,j) \in
    \mathcal{E}`.

    Args:
        edge_index (LongTensor): The edge indices.
        num_nodes (int, optional): The number of nodes, *i.e.*
            :obj:`max_val + 1` of :attr:`edge_index`. (default: :obj:`None`)

    :rtype: :class:`LongTensor`
    """
    num_nodes = maybe_num_nodes(edge_index, num_nodes)

    row, col = edge_index
    row, col = torch.cat([row, col], dim=0), torch.cat([col, row], dim=0)

    edge_index = torch.stack([row, col], dim=0)
    # edge_index, _ = coalesce(edge_index, None, num_nodes, num_nodes)

    return edge_index


class GraphData(Data):

    @staticmethod
    def fromData(data: Data):
        g = GraphData(**data.__dict__)
        return g

    @property
    def inEdges(self):
        return self.edge_index * self.inEdgeMask

    @property
    def outEdges(self):
        return self.edge_index * self.outEdgeMask

    def __init__(
        self,
        x=None,
        edge_index=None,
        edge_attr=None,
        y=None,
        pos=None,
        normal=None,
        face=None,
        makeUndirected=True,
        trainSplit=0.7,
        makeSparse=False,
        **kwargs
    ):
        if isinstance(y, list):
            y = np.array(y)
        super().__init__(x=x,
                         edge_index=edge_index,
                         edge_attr=edge_attr,
                         y=y,
                         pos=pos,
                         normal=normal,
                         face=face,
                         **kwargs)

        self.directed_edges = edge_index.clone().detach().requires_grad_(False) if edge_index is not None else None
        self.numOutEdges = None
        self.outEdgeMask = None
        self.inEdgeMask = None
        self.selfEdgeMask = None
        self.num_nodes = self.x.shape[0] if self.x is not None else None
        self._insertedNodes = None

        if makeUndirected and self.is_directed():
            self.numOutEdges = self.edge_index.shape[1]
            self.edge_index = to_undirected_no_sort(self.edge_index)
            self.edge_index, _ = add_remaining_self_loops(self.edge_index)
            outEdges = []
            inEdges = []
            selfEdges = []
            for i in range(self.edge_index.shape[1]):
                if i < self.numOutEdges:
                    outEdges.append(1), inEdges.append(0), selfEdges.append(0)
                elif i < self.numOutEdges * 2:
                    outEdges.append(0), inEdges.append(1), selfEdges.append(0)
                else:
                    outEdges.append(0), inEdges.append(0), selfEdges.append(1)
            self.outEdgeMask = torch.tensor(outEdges, requires_grad=False)
            self.inEdgeMask = torch.tensor(inEdges, requires_grad=False)
            self.selfEdgeMask = torch.tensor(selfEdges, requires_grad=False)

        if makeSparse:
            self.adj = SparseTensor(
                row=self.edge_index[0],
                col=self.edge_index[1],
                value=None,
                sparse_sizes=(self.num_nodes, self.num_nodes)
            )

        if self.y is not None:
            split = trainValTestSplit(self.y, trainSize=trainSplit)
            self.trainMask, self.valMask, self.testMask = (
                torch.tensor(split.train),
                torch.tensor(split.val),
                torch.tensor(split.test)
            )

    def draw(self, title=None):
        ng.Graph.drawGraph(to_networkx(Data(x=self.x, edge_index=self.directed_edges)), title=title)

    def to_networkx(
        self,
        node_attrs=None,
        edge_attrs=None,
        to_undirected=False,
        remove_self_loops=False
    ):
        r"""Converts a :class:`torch_geometric.data.Data` instance to a
        :obj:`networkx.Graph` if :attr:`to_undirected` is set to :obj:`True`, or
        a directed :obj:`networkx.DiGraph` otherwise.

        Args:
            self (torch_geometric.data.Data): The data object.
            node_attrs (iterable of str, optional): The node attributes to be
                copied. (default: :obj:`None`)
            edge_attrs (iterable of str, optional): The edge attributes to be
                copied. (default: :obj:`None`)
            to_undirected (bool, optional): If set to :obj:`True`, will return a
                a :obj:`networkx.Graph` instead of a :obj:`networkx.DiGraph`. The
                undirected graph will correspond to the upper triangle of the
                corresponding adjacency matrix. (default: :obj:`False`)
            remove_self_loops (bool, optional): If set to :obj:`True`, will not
                include self loops in the resulting graph. (default: :obj:`False`)
        """
        import networkx as nx

        if to_undirected:
            G = nx.Graph()
        else:
            G = nx.DiGraph()

        G.add_nodes_from(range(self.num_nodes))

        node_attrs, edge_attrs = node_attrs or [], edge_attrs or []

        values = {}
        for key, item in self(*(node_attrs + edge_attrs)):
            if torch.is_tensor(item):
                values[key] = item.squeeze().tolist()
            else:
                values[key] = item
            if isinstance(values[key], (list, tuple)) and len(values[key]) == 1:
                values[key] = item[0]

        for i, (u, v) in enumerate(self.directed_edges.t().tolist()):

            if to_undirected and v > u:
                continue

            if remove_self_loops and u == v:
                continue

            G.add_edge(u, v)

            for key in edge_attrs:
                G[u][v][key] = values[key][i]

        for key in node_attrs:
            for i, feat_dict in G.nodes(data=True):
                try:
                    feat_dict.update({key: values[key][i]})
                except KeyError:
                    feat_dict.update({key: self.x[i, self.node_features.index(key)]})


        return G

    # Insertion Helpers
    def getFanInMask(self, nodeIdx):
        """
            Returns a mask for the nodes where
            True == non-masked (included) -- i.e. IS a fan-in node
            False == masked (excluded) -- i.e. is NOT a fan-in node

            :param nodeIdx: index of node to calculate fan in for
            :return: node mask
        """
        return getFanInMask(self.to_networkx(), nodeIdx)

    def _addDirectedEdge(self, source, target, edges):
        newCol = torch.tensor([
            [source],
            [target]
        ]).type_as(self.edge_index)
        return torch.cat((edges, newCol), dim=1)

    def _addBiDirectionalEdge(self, source, target, edges, selfLoop='target'):
        if selfLoop == 'target':
            newCol = torch.tensor([
                [source, target, target],
                [target, source, target]
            ]).type_as(edges)
        elif selfLoop == 'source':
            newCol = torch.tensor([
                [source, target, source],
                [target, source, source]
            ]).type_as(edges)
        elif selfLoop == 'both':
            newCol = torch.tensor([
                [source, target, source, target],
                [target, source, source, target]
            ]).type_as(edges)
        else:
            newCol = torch.tensor([
                [source, target],
                [target, source]
            ]).type_as(edges)
        return torch.cat((edges, newCol), dim=1)

    def insertNode(self, atNodeIdx: int, featureVector, reverse=False):

        # Add node to feature vector
        assert len(featureVector) == self.x.shape[1]
        self.x = torch.cat((self.x, torch.tensor(featureVector).view(1, -1)), 0)
        # newNodeIdx = self.x.shape[0] - 1

        if reverse:
            newNodeIdx = atNodeIdx
            atNodeIdx = self.x.shape[0] - 1
        else:
            newNodeIdx = self.x.shape[0] - 1

        # Append connections to edge_index
        if reverse:
            self.edge_index = self._addBiDirectionalEdge(atNodeIdx, newNodeIdx, self.edge_index, selfLoop='source')
        else:
            self.edge_index = self._addBiDirectionalEdge(atNodeIdx, newNodeIdx, self.edge_index, selfLoop='target')

        # Add connection to directed_edges
        self.directed_edges = self._addDirectedEdge(atNodeIdx, newNodeIdx, self.directed_edges)

        # Update masks
        self.outEdgeMask = torch.cat((self.outEdgeMask, torch.tensor([1, 0, 0])), 0)
        self.inEdgeMask = torch.cat((self.inEdgeMask, torch.tensor([0, 1, 0])), 0)
        self.selfEdgeMask = torch.cat((self.selfEdgeMask, torch.tensor([0, 0, 1])), 0)

        # keep track of inserted nodes
        if self._insertedNodes is None:
            self._insertedNodes = []

        if reverse:
            self._insertedNodes.append(atNodeIdx)
            return atNodeIdx
        else:
            self._insertedNodes.append(newNodeIdx)
            return newNodeIdx

    def popInsertedNode(self):
        if self._insertedNodes is None or len(self._insertedNodes) == 0:
            return None

        latestCP = self._insertedNodes[-1]

        self.removeInsertedNode(latestCP)

        return latestCP

    def removeInsertedNode(self, withNodeIdx):

        if withNodeIdx not in self._insertedNodes:
            return

        def _getKeepIndices(_edgeTensor):
            colIdxs = np.unique(np.argwhere((_edgeTensor == withNodeIdx).detach().numpy())[1, :])
            _includeIdxs = list(np.arange(_edgeTensor.shape[1]))
            for idx in colIdxs:
                _includeIdxs.remove(idx)
            _includeIdxs.sort()
            return _includeIdxs

        # remove edges and mask entries associated with remaining indices
        includeIdxs = _getKeepIndices(self.edge_index)
        self.edge_index = self.edge_index[:, includeIdxs]
        self.outEdgeMask = self.outEdgeMask[includeIdxs]
        self.inEdgeMask = self.inEdgeMask[includeIdxs]
        self.selfEdgeMask = self.selfEdgeMask[includeIdxs]

        includeIdxs = _getKeepIndices(self.directed_edges)
        self.directed_edges = self.directed_edges[:, includeIdxs]

        try:
            self._insertedNodes.remove(withNodeIdx)
        except ValueError:
            pass
