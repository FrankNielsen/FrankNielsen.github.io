#!/usr/bin/env python

from embed import embed, MODEL_ARR, DATA_ARR

import optuna
from optuna.trial import TrialState
optuna.logging.set_verbosity( optuna.logging.WARNING )

from datetime import datetime

import numpy as np
import time
import sys, argparse, itertools
from termcolor import colored

BATCHSIZE=16

def tune( data, model, dim, epochs, prob, seed, n_trials ):
    '''
    find the best learning rate
    '''

    def run_config( trial ):
        lr = trial.suggest_float( 'lr', 1e-3, 1.0 )

        loss, _ = embed( data, model, dim, epochs, BATCHSIZE, lr, prob, seed, False, False )
        return loss

    study = optuna.create_study()
    study.optimize( run_config, n_trials=n_trials )
    trial = study.best_trial

    return trial.value, trial.params['lr']

def main():
    parser = argparse.ArgumentParser( description='random experiments' )

    parser.add_argument( 'data',  choices=DATA_ARR, help='data' )
    parser.add_argument( 'model', choices=MODEL_ARR, help='model' )

    parser.add_argument( '--dim', type=int, nargs='+',
                         default=[ 2, 5, 10, 20, 50 ],
                         help='embedding dimensionality' )

    parser.add_argument( '--prob', action='store_true', default=False,
                         help='embed probabilities' )

    parser.add_argument( '--seeds', type=int, default=10,
                         help='number of seeds (data instances)' )

    parser.add_argument( '--trials', type=int, default=20,
                         help='max #trials to run for each configuration' )

    parser.add_argument( '--epochs', type=int, default=3000,
                         help='max number of epochs' )

    args = parser.parse_args()

    # seed corresponds to different instances of the random dataset
    SEED_ARR  = range( 2023, 2023+args.seeds )

    start_t = time.time()

    timestamp = datetime.now().strftime( "%m_%d_%Y_%H:%M" )
    FILENAME = f'{args.data}_{args.model}_{timestamp}'
    if args.prob: FILENAME += '_prob'
    FILENAME += '.log'
    print( f'logging to {FILENAME}' )

    with open( FILENAME, 'w') as ofile:
        for dim in args.dim:
            # set the learning rate based on the first random seed
            seed = SEED_ARR[0]
            print( colored( f'running {dim}D {args.model} on {args.data} data (seed={seed})', 'red' ) )

            loss, _lr = tune( args.data, args.model, dim, args.epochs, args.prob, seed, args.trials )
            if dim == args.dim[0]: baseline_loss = loss

            msg = f'{args.data} {args.model} {args.prob} {dim} {seed} {_lr:.4f} {BATCHSIZE} {loss}\n'
            print( msg, end='' )
            sys.stdout.flush()
            ofile.write( msg )

            for seed in SEED_ARR[1:]:
                print( colored( f'running {dim}D {args.model} on {args.data} data (seed={seed})', 'red' ) )

                loss, _ = embed( args.data, args.model, dim, args.epochs,
                                 BATCHSIZE, _lr, args.prob, seed, False, False )

                if dim > args.dim[0] and loss > baseline_loss:
                    # skip failed runs (due to numerical statiblity, poor initialization, etc.)
                    # optionally run again with a smaller learning rate
                    print( 'failed run' )

                else:
                    msg = f'{args.data} {args.model} {args.prob} {dim} {seed} {_lr:.4f} {BATCHSIZE} {loss}\n'
                    print( msg, end='' )
                    sys.stdout.flush()
                    ofile.write( msg )

    time_cost = time.time() - start_t
    print( f'finished in {time_cost/3600:.1f} hours' )

if __name__ == '__main__':
    main()
