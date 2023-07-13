import math
import torch
import torch.nn as nn

from warnings import warn

def randomprobs( n, d ):
    '''
    (Deprecated)

    random probabilities (logits)
    '''

    warn( 'deprecated init method', DeprecationWarning )

    m = torch.distributions.dirichlet.Dirichlet( 10.0 * torch.ones(d) )
    points = m.sample( (n,) )
    return torch.log( points + 1e-10 )

def randompoints( n, dim ):
    '''
    random points of shape nxdim
    '''
    stdv = 1 / math.sqrt(dim)

    m = torch.distributions.normal.Normal(
            torch.zeros(dim),
            stdv * torch.ones(dim) )

    points = m.sample( (n,) )
    return points

class Geometry( nn.Module ):
    def __init__( self, n, dim, device, init=None ):
        '''
        randomly initialize n points in the underlying geometry

        dim is the dimensionality of the manifold
        '''
        super( Geometry, self ).__init__()

        if init is None:
            points = randompoints( n, dim )
            points = points.clone().detach().requires_grad_( True ).to( device )

        else:
            points = torch.tensor( init,
                                   dtype=torch.float32,
                                   requires_grad=True,
                                   device=device )

        self.register_parameter( 'points',
                                 torch.nn.Parameter( points ) )


class Euclidean( Geometry ):
    @staticmethod
    def __distance2( x, y ):
        x2 = torch.sum( torch.square( x ), dim=1, keepdim=True )
        y2 = torch.sum( torch.square( y ), dim=1, keepdim=True )
        xy = torch.matmul( x, y.t() )
        # our implementation of the distance computation is not memory efficient

        dist2 = x2 + y2.t() - 2 * xy

        return torch.clamp( dist2, min=1e-10 )

    def __init__( self, n, dim, device, init=None ):
        super( Euclidean, self ).__init__( n, dim, device, init )

    def forward( self, idx ):
        '''
        idx: a list of index
        '''
        return torch.sqrt( Euclidean.__distance2( self.points[idx], self.points ) )

class L1( Geometry ):
    @staticmethod
    def __distance( x, y ):
        return torch.sum( torch.abs( x[:,None,:] - y[None,:,:] ), dim=2 )

    def __init__( self, n, dim, device, init=None ):
        super( L1, self ).__init__( n, dim, device, init )

    def forward( self, idx ):
        '''
        idx: a list of index (corresponding to a subset)
        '''
        return L1.__distance( self.points[idx], self.points )

class HSG( Geometry ):
    @staticmethod
    def __distance( x, y ):
        '''
        the HSG is represented an isometric vector space
        '''

        diff = x[:,None,:] - y[None,:,:]

        maxv, _maxi = torch.max( diff, dim=2 )
        minv, _mini = torch.min( diff, dim=2 )
        hilbert = maxv - minv

        return hilbert

    def __init__( self, n, dim, device, init=None ):
        '''
        the Hilbert simplex has dimensionality dim, and the number
        of coordinates (probabilities) is (dim+1)
        '''
        super( HSG, self ).__init__( n, dim+1, device, init )

    def forward( self, idx ):
        return HSG.__distance( self.points[idx], self.points )

class HSGT( Geometry ):
    def __distance( self, x, y ):
        '''
        the HSG is represented an isometric vector space
        '''

        diff = x[:,None,:] - y[None,:,:]

        dist = torch.logsumexp( diff * self.T, dim=2 ) / self.T
        dist += torch.logsumexp( -diff * self.T, dim=2 ) / self.T

        return dist

    def __init__( self, T, n, dim, device, init=None ):
        '''
        data is float tensor of shape Nxdim
        '''
        super( HSGT, self ).__init__( n, dim+1, device, init )
        self.T = T

    def forward( self, idx ):
        return self.__distance( self.points[idx], self.points )

class Funk( Geometry ):
    @staticmethod
    def __distance( x, y ):
        logx = x - torch.logsumexp( x, dim=1, keepdims=True )
        logy = y - torch.logsumexp( y, dim=1, keepdims=True )

        return ( logx[:,None,:] - logy[None,:,:] ).amax( dim=2 )

    def __init__( self, n, dim, device, init=None ):
        super( Funk, self ).__init__( n, dim+1, device, init )

    def forward( self, idx ):
        return Funk.__distance( self.points[idx], self.points )

class Aitchison( Geometry ):
    '''
    representation power of the Aitchison simplex is equivalent to Euclidean space
    '''
    @staticmethod
    def __distance2( x, y ):
        clrx = x - torch.mean( x, dim=1, keepdim=True )
        clry = y - torch.mean( y, dim=1, keepdim=True )

        x2 = torch.sum( torch.square( clrx ), dim=1, keepdim=True )
        y2 = torch.sum( torch.square( clry ), dim=1, keepdim=True )
        xy = torch.matmul( clrx, clry.t() )

        dist2 = x2 + y2.t() - 2 * xy

        return torch.clamp( dist2, min=1e-10 )

    def __init__( self, n, dim, device, init=None ):
        '''
        dim+1 probabilities for dimensionality = dim
        '''
        super( Aitchison, self ).__init__( n, dim+1, device, init )

    def forward( self, idx ):
        return torch.sqrt( Aitchison.__distance2( self.points[idx], self.points ) )

class Poincare( Geometry ):
    '''
    Poincare Hyperboloid model
    '''
    @staticmethod
    def __distance( x, y ):

        x0 = 1 + torch.sum( torch.square( x ), 1, keepdim=True )
        y0 = 1 + torch.sum( torch.square( y ), 1, keepdim=True )

        dot = torch.sqrt( x0 * y0.t() ) - torch.matmul( x, y.t() )

        mat = torch.acosh( torch.clamp( dot, min=1+1e-4 ) )

        return mat

    def __init__( self, n, dim, device, init=None ):
        '''
        Gaussian initialization
        '''
        super( Poincare, self ).__init__( n, dim, device, init )

    def forward( self, idx ):
        return Poincare.__distance( self.points[idx], self.points )
