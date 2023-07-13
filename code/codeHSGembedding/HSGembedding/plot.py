#!/usr/bin/env python

import matplotlib
import matplotlib.pyplot as plt

matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype']  = 42
matplotlib.rcParams['font.family'] = "serif"
matplotlib.rcParams['font.size'] = 10
matplotlib.rcParams['text.usetex'] = True

import numpy as np
import os, sys
from collections import defaultdict

COLORS  = [ 'tab:blue',
            'tab:orange',
            'tab:red',
            'tab:green',
            'tab:purple',
            'tab:brown',
            'tab:olive',
          ]
MARKERS = [ 'd',  'o',  '*', '+', 'X',  's',  '2' ]
LS      = [ '-', '-.', '--', ':', '-', '--', '-'  ]

MODELNAMES = {
        'Euclidean' : 'Euclidean',
        'L1'        : r'$L_1$',
        'Poincare'  : r'Hyperboloid',
        'Aitchison' : 'Aitchison',
        'HSG'       : 'Hilbert',
        'HSGT'      : 'Hilbert (T)',
        'Funk'      : 'Funk',
        }

def construct_db( filenames, prob ):
    DB = defaultdict( list )

    for filename in filenames:
        for line in open( filename ):
            line = line.strip()
            if not line: continue

            _data, _model, _prob, _dim, _seed, _lrate, _batchsize, _loss = line.split()
            if str(prob) == _prob:
                DB[(_data,_model)].append(
                        ( int(_dim),
                          float(_loss),
                          float(_lrate),
                          float(_batchsize) ) )
    return DB

def draw( filenames, prob ):
    print( 'processing' )
    print( '\n'.join( filenames ) )

    DB = construct_db( filenames, prob )
    if len(DB) == 0: return

    # print( 'best batchsize:' )
    # print( min( best_batchsize ), max( best_batchsize ), np.mean( best_batchsize ) )
    # print( 'best learning rates:' )
    # print( min( best_lr ),        max( best_lr ),        np.mean( best_lr ) )

    DATA = set( [ _data for _data,_model in DB ] )
    DBMODELS = set( [ _model for _data,_model in DB ] )
    MODEL = [ m for m in MODELNAMES if m in DBMODELS ]

    DIMS = set()
    for _l in DB.values():
        for _dim, _loss, _lrate, _batchsize in _l:
            DIMS.add( _dim )
    DIMS = list( DIMS )
    DIMS.sort()

    for data in DATA:
        fig = plt.figure( figsize=(4,3), dpi=200 )
        ax = fig.add_axes( [0,0,1,1] )

        for model, c, m, ls in zip( MODEL, COLORS, MARKERS, LS ):
            entries = sorted( DB[(data,model)], key=lambda r: r[0] )

            x    = []
            mean = []
            std  = []

            for i, d in enumerate( DIMS ):
                _loss_arr = [ r[1] for r in entries if ( r[0] == d ) ]
                if _loss_arr:
                    x.append( i )
                    mean.append( np.mean( _loss_arr ) )
                    std.append( np.std( _loss_arr ) )

            x = np.array( x )
            mean = np.array( mean )
            std = np.array( std )

            ax.plot( x, mean, label=f'{MODELNAMES[model]}', color=c, marker=m, ls=ls )
            ax.fill_between( x, mean-std, mean+std, color=c, alpha=.3 )

        ax.set_xlabel( '$d$' )
        ax.set_xticks( range( len(DIMS) ) )
        ax.set_xticklabels( DIMS )

        ax.set_yscale( 'log' )
        if prob:
            ax.set_ylabel( '$\ell(\mathcal{P},\,\mathcal{M}^d)$' )
        else:
            ax.set_ylabel( '$\ell(\mathcal{D},\,\mathcal{M}^d)$' )

        ax.legend( loc='best', handlelength=5, numpoints=2 )

        ofilename = data + '_rw.pdf' if prob else data + '.pdf'
        fig.savefig( ofilename, bbox_inches='tight' )

def main():
    # usage:
    # ./plot.py
    legalnames = [ f for f in sys.argv[1:] if os.access( f, os.R_OK ) ]
    draw( legalnames, True )
    draw( legalnames, False )

if __name__ == '__main__':
    main()
