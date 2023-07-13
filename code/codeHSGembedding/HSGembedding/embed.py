from geometries import Euclidean, L1, HSG, HSGT, Funk, Aitchison, Poincare

import torch
import torch.nn.functional as F

import random
import numpy as np

import sys, argparse

MODEL_ARR = [
              Aitchison.__name__,
              HSG.__name__,
              HSGT.__name__,
              Funk.__name__,
              Euclidean.__name__,
              Poincare.__name__,
              L1.__name__,
            ]

DATA_ARR = [ 'random100', 'random500',
             'erdos0.05', 'erdos0.2', 'erdos0.5',
             'barabasi1', 'barabasi2', 'barabasi3',
             'newman0.2', 'newman0.5',
             'tree',
             'karate',
             'facebook' ]

def train( data, model, device, optimizer, batchsize, prob ):
    '''
    train for one epoch
    '''
    model.train()

    n = data.shape[0]
    allidx = torch.randperm( n )

    batchsize = min( batchsize, n )
    n_batches = int( np.ceil( n/batchsize ) )

    for i in range( n_batches ):
        optimizer.zero_grad()

        idx = allidx[i*batchsize:(i+1)*batchsize]

        _distance = model( idx )
        if prob:
            # KL divergence
            sq_distance = torch.square( _distance )

            idx_all = torch.arange(n).view(1,n).expand_as( _distance )
            mask = idx.view(-1,1).expand_as( idx_all ) != idx_all
            sq_distance_except_self = sq_distance[mask].view(-1, n-1)

            loss = torch.mean(
                    torch.sum( data[idx] * sq_distance, dim=1 ) \
                  + torch.logsumexp( -sq_distance_except_self, dim=1 )
                  )

        else:
            # stress function
            loss = torch.mean( torch.square( _distance - data[idx] ) )

        loss.backward()
        optimizer.step()

def evaluate( data, model, device, prob ):
    '''
    no need mini-batches for evaluation
    '''
    model.eval()

    EPS = torch.finfo( torch.float32 ).eps

    allidx = torch.arange( data.shape[0], device=device )
    _distance = model( allidx )

    if prob:
        q = torch.exp( -torch.square( _distance ) )
        q.fill_diagonal_( 0 )
        sumq = torch.sum( q, dim=1, keepdims=True )
        q = q / torch.clamp( sumq, min=EPS )

        loss = torch.mean(
                torch.sum( data * torch.log( torch.clamp( data, min=EPS ) )
                         - data * torch.log( torch.clamp( q, min=EPS ) ),
                dim=1 ) )

    else:
        loss = torch.mean( torch.square( _distance - data ) )

    return loss.cpu().detach().numpy()

def entropy( arr, tau ):
    '''
    entropy of exp(-arr/tau)/ exp(-arr/tau).sum()
    '''
    EPS = 1e-7
    s = np.exp( -arr / tau )
    return (s * arr).sum() / np.maximum( tau*s.sum(), EPS ) \
           + np.log( np.maximum( s.sum(), EPS ) )

def generate_random_data( n, device, chaos, prob, verbose, perplexity=30 ):
    '''
    random points (normal distribution)

    return the pairwise distance/similarity matrix (pytorch tensor)
    '''
    dim = n
    data = chaos.randn( n, dim )

    sq2 = (data**2).sum(1)
    dot = np.dot( data, data.T )
    sq_distance = np.maximum( sq2[None,:] + sq2[:,None] - 2*dot, 0 )

    EPS = 1e-7
    if prob:
        tau_arr = []
        # entropy normalization for each probability vector
        for i in range( n ):
            tau_small = EPS
            tau_large = float( 'inf' )
            tau = 1

            while abs( entropy( np.delete( sq_distance[i], i ), tau ) - np.log(perplexity) ) > EPS:
                if entropy( np.delete( sq_distance[i], i ), tau ) > np.log(perplexity):
                    tau_large = tau
                    tau = (tau_small+tau_large)/2
                else:
                    tau_small = tau
                    if tau_large == float( 'inf' ):
                        tau = tau_small * 2
                    else:
                        tau = (tau_small+tau_large)/2
            tau_arr.append( tau )
        tau_arr = np.array( tau_arr )
        p = np.exp( -sq_distance/tau_arr[:,None] )
        np.fill_diagonal( p, 0 )
        sump = p.sum( 1, keepdims=True )
        mat = p / np.maximum( sump, EPS )

        ent = np.exp( ( -mat * np.log( np.maximum( mat, EPS ) ) ).sum(1) )
        print( f'perplexity: {ent.min()} - {ent.max()}' )

    else:
        mat = np.sqrt( sq_distance )
        _std = mat.std()
        mat /= _std

    return torch.tensor( mat, dtype=torch.float32, device=device )

def generate_graph( name, n, device, chaos, prob, verbose ):
    '''
    graph generator

    n - number of nodes

    return the pairwise distance/similarity matrix (pytorch tensor)
    '''
    import networkx as nx

    if name.startswith( 'erdos' ):
        p = float( name[5:] )
        g = nx.erdos_renyi_graph( n, p, seed=chaos )

    elif name.startswith( 'barabasi' ):
        m = int( name[8:] )
        g = nx.barabasi_albert_graph( n, m, seed=chaos )

    elif name.startswith( 'newman' ):
        p = float( name[6:] )
        g = nx.newman_watts_strogatz_graph( n, 4, p )

    elif name == 'tree':
        g = nx.random_tree( n )

    elif name == 'karate':
        g = nx.karate_club_graph()

    elif name == 'facebook':
        g = nx.read_edgelist( 'facebook/0.edges' )

    else:
        raise RuntimeError( f'unknown graph: {name}' )

    cc = max( nx.connected_components(g), key=len )
    g = g.subgraph(cc).copy()

    if prob:
        A = nx.adjacency_matrix( g )
        A = A.todense()
        A = np.array( A, dtype=np.float32 )
        rowsum = A.sum( 1, keepdims=True )
        T = A / rowsum

        # random walk similarity (5 steps)
        #A = np.array( [ np.linalg.matrix_power( T, _s ) for _s in range(1,6) ] ).sum(0)
        A = np.linalg.matrix_power( T, 5 )

        # ignore self-similarity, renormalize
        np.fill_diagonal( A, 0 )
        rowsum = A.sum( 1, keepdims=True )
        data = A / rowsum

    else:
        data = nx.algorithms.shortest_paths.dense.floyd_warshall_numpy( g )

        num_nodes = data.shape[0]
        data = np.nan_to_num( data, posinf=num_nodes )
        data = np.minimum( data, num_nodes )

    if verbose:
        print( g.number_of_nodes(), 'nodes' )
        print( g.number_of_edges(), 'edges' )
        print( 'max:', data.max() )

    return torch.tensor( data, dtype=torch.float32, device=device )

def embed( data,
           model,
           dim,
           epochs,
           batchsize,
           lr,
           prob,
           seed,
           no_cuda,
           verbose,
         ):
    '''
    wrapper function
    '''
    use_cuda = not no_cuda and torch.cuda.is_available()
    device = torch.device( "cuda" if use_cuda else "cpu" )

    torch.manual_seed( seed )
    random.seed( seed )
    np.random.seed( seed )
    chaos = np.random.RandomState( seed )

    if verbose:
        print( '=====' )
        print( f'running {dim}D {model} on {data} data' )

    if data.startswith( 'random' ):
        data = generate_random_data( int(data[6:]), device, chaos, prob, verbose )

    elif data.startswith( 'erdos' ):
        data = generate_graph( data, 200, device, chaos, prob, verbose )

    elif data.startswith( 'barabasi' ):
        data = generate_graph( data, 200, device, chaos, prob, verbose )

    elif data.startswith( 'newman' ):
        data = generate_graph( data, 200, device, chaos, prob, verbose )

    elif data == 'karate':
        data = generate_graph( 'karate', None, device, chaos, prob, verbose )

    elif data == 'tree':
        data = generate_graph( 'tree', 200, device, chaos, prob, verbose )

    elif data == 'facebook':
        data = generate_graph( 'facebook', None, device, chaos, prob, verbose )

        #data = np.load('facebook.npz')['mat']
        #data = torch.tensor( data, dtype=torch.float32, device=device )

    else:
        raise RuntimeError( f'unknown data set: {data}' )

    n = data.shape[0]
    data = data.to( device )

    if model == 'HSGT':
        model = eval( model )( 5, n, dim, device ) # use T=5
    else:
        model = eval( model )( n, dim, device )

    optimizer = torch.optim.Adam( model.parameters(), lr=lr )

    loss = []
    if epochs > 200:
        OUTPUT_INTV = 100
    else:
        OUTPUT_INTV = 10

    PATIENCE = 15
    MIN_EPOCHS = max( int( np.ceil( epochs * 0.1 ) ), PATIENCE )

    for epoch in range( 1, epochs + 1 ):
        train( data, model, device, optimizer, batchsize, prob )

        loss.append( evaluate( data, model, device, prob ) )

        if verbose and epoch % OUTPUT_INTV == 0:
            print( f'epoch{epoch}: loss={loss[-1]}' )

        if len( loss ) >= max( MIN_EPOCHS, PATIENCE+1 ):
            if min( loss[-PATIENCE:] ) >  min( loss[:-PATIENCE] ):
                # didn't reduce loss in the last few epochs, early stop
                break

    return min(loss), len(loss)

def main():
    parser = argparse.ArgumentParser( description='embedding into different geometries' )

    parser.add_argument( 'data',  choices=DATA_ARR,
                         help='name of data set' )

    parser.add_argument( 'model', choices=MODEL_ARR,
                         help='embedding space' )

    parser.add_argument( '--prob', action='store_true', default=False,
                         help='embed probabilities (instead of distances)' )

    parser.add_argument( '--no-cuda', action='store_true', default=False,
                         help='disables CUDA training' )

    parser.add_argument( '--verbose', type=bool, default=True,
                         help='say more during running' )

    parser.add_argument( '--epochs', type=int, default=3000, metavar='N',
                         help='number of epochs to train' )

    parser.add_argument( '--batchsize', type=int, default=8,
                         help='mini-batch size' )

    parser.add_argument( '--dim', type=int, default=10, metavar='DIM',
                         help='dimensionality' )

    parser.add_argument( '--seed', type=int, default=2023, metavar='S',
                         help='random seed' )

    parser.add_argument( '--lr', type=float, default=1e-3, metavar='LR',
                         help='learning rate' )

    args = parser.parse_args()

    embed( args.data, args.model, args.dim, args.epochs,
           args.batchsize, args.lr, args.prob,
           args.seed, args.no_cuda, args.verbose )

if __name__ == '__main__':
    main()
