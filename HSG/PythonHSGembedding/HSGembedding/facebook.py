#!/usr/bin/env python

import networkx as nx
import numpy as np

g = nx.read_edgelist( 'facebook_combined.txt' )
mat = nx.algorithms.shortest_paths.dense.floyd_warshall_numpy( g )
np.savez( 'facebook.npz', mat=mat )
