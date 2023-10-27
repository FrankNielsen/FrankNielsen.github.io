import numpy as np

import matplotlib
import matplotlib.pyplot as plt

matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype']  = 42
matplotlib.rcParams['font.family'] = "serif"
matplotlib.rcParams['font.size'] = 10
matplotlib.rcParams['text.usetex'] = True

EPS = np.finfo( np.float32 ).eps

def randomprobs( n, d ):
    probs = np.random.dirichlet( np.ones(d), size=n )
    idx = np.all( probs > EPS, axis=1 )
    X = probs[idx]

    #n, _ = X.shape
    #print( f'{n} valid entries' )

    return X

def compute_error( n, d, T ):

    X = randomprobs( n, d )
    Y = randomprobs( n, d )
    n = min( X.shape[0], Y.shape[0] )
    X = X[:n]
    Y = Y[:n]

    logx = np.log( np.maximum( X, EPS ) )
    logy = np.log( np.maximum( Y, EPS ) )

    hilbert = ( logx - logy ).max(1) - ( logx - logy ).min(1)

    UB = np.log( np.power( X/(Y+EPS), T ).sum(1) ) \
         + np.log( np.power( Y/(X+EPS), T ).sum(1) )
    UB /= T

    err = (UB-hilbert) / (hilbert+EPS)

    return hilbert, err

fig = plt.figure( figsize=(12,3), dpi=200 )
ax1 = fig.add_subplot(131)
ax2 = fig.add_subplot(132)
ax3 = fig.add_subplot(133)

n=1_000_000
for d in [ 3, 6, 11, 21, 51 ]:
    dist, err1 = compute_error( n, d, 1 )
    dist, err5 = compute_error( n, d, 5 )
    ax1.hist( dist, bins=50, histtype='step', density=True,
              label=r'$\rho_{\mathrm{HG}}$' + f' (d={d-1})', alpha=.5 )
    ax2.hist( err1, bins=50, histtype='step', density=True,
              label=r'$\mathrm{err}^T$ ' + f'($d={d-1}$, $T=1$)', alpha=.5 )
    ax3.hist( err5, bins=50, histtype='step', density=True,
              label=r'$\mathrm{err}^T$ ' + f'($d={d-1}$, $T=5$)', alpha=.5 )

ax1.legend( loc='best', handlelength=2, fancybox=True, framealpha=0.5 )
ax1.set_xlabel( 'Hilbert distance' )
ax1.set_yticklabels([])

ax2.legend( loc=1, handlelength=2, fancybox=True, framealpha=0.5 )
ax2.set_xlim( [0,1] )
ax2.set_xlabel( 'Relative Error $(T=1)$' )
ax2.set_yticklabels([])

ax3.legend( loc=1, handlelength=2, fancybox=True, framealpha=0.5 )
ax3.set_xlim( [0,.2] )
ax3.set_xlabel( 'Relative Error $(T=5)$' )
ax3.set_yticklabels([])

fig.savefig( 'bound.pdf', bbox_inches='tight' )
