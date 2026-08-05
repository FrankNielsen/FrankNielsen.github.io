import java.util.*;

  class PowerMEBWelzl {

    static final double EPS = 1e-12;

    // Weighted point: {x,y,w}
    // where w is the squared weight (r^2)
    
    public static double[] powerMiniball(double[][] pts) {

        ArrayList<double[]> P = new ArrayList<>();

        for (double[] p: pts)
            P.add(p.clone());

        Collections.shuffle(P, new Random());

        return welzl(P, new ArrayList<>(), P.size());
    }


    private static double[] welzl(
            ArrayList<double[]> P,
            ArrayList<double[]> B,
            int n) {

        // trivial solution
        if (n == 0 || B.size() == 3)
            return trivial(B);


        double[] p = P.get(n-1);

        // ball without p
        double[] D = welzl(P,B,n-1);


        if (contains(D,p))
            return D;


        // p is a boundary point
        B.add(p);

        double[] R = welzl(P,B,n-1);

        B.remove(B.size()-1);

        return R;
    }



    // Check power containment
    private static boolean contains(
            double[] ball,
            double[] p) {

        double dx=p[0]-ball[0];
        double dy=p[1]-ball[1];

        double power =
            dx*dx+dy*dy-p[2];

        return power <= ball[2]+EPS;
    }



    // Solve boundary problem |B| <= 3
    private static double[] trivial(
            ArrayList<double[]> B) {

        if (B.size()==0)
            return new double[]{0,0,
                    Double.NEGATIVE_INFINITY};


        if (B.size()==1) {
            double[] p=B.get(0);
            return new double[]{
                    p[0],p[1],-p[2]};
        }


        if (B.size()==2)
            return ball2(B.get(0),B.get(1));


        return ball3(
                B.get(0),
                B.get(1),
                B.get(2));
    }



    // Two-point power ball
    private static double[] ball2(
            double[] a,
            double[] b) {

        double dx=b[0]-a[0];
        double dy=b[1]-a[1];

        double d2=dx*dx+dy*dy;


        double t=(d2+a[2]-b[2])
                /(2*d2);


        double cx=a[0]+t*dx;
        double cy=a[1]+t*dy;


        double R =
            (cx-a[0])*(cx-a[0])
           +(cy-a[1])*(cy-a[1])
           -a[2];


        return new double[]{cx,cy,R};
    }



    // Three-point power circumcenter
    private static double[] ball3(
            double[] a,
            double[] b,
            double[] c) {


        double A11=2*(b[0]-a[0]);
        double A12=2*(b[1]-a[1]);

        double A21=2*(c[0]-a[0]);
        double A22=2*(c[1]-a[1]);


        double B1 =
            b[0]*b[0]+b[1]*b[1]
           -a[0]*a[0]-a[1]*a[1]
           +a[2]-b[2];


        double B2 =
            c[0]*c[0]+c[1]*c[1]
           -a[0]*a[0]-a[1]*a[1]
           +a[2]-c[2];


        double det=A11*A22-A12*A21;


        if (Math.abs(det)<EPS) {
            // collinear: fall back
            return ball2(a,b);
        }


        double x =
            (B1*A22-A12*B2)/det;

        double y =
            (A11*B2-B1*A21)/det;


        double R =
            (x-a[0])*(x-a[0])
           +(y-a[1])*(y-a[1])
           -a[2];


        return new double[]{x,y,R};
    }



    // test
    public static void main(String[] args) {

        double[][] pts = {
            {0,0,1},
            {4,0,4},
            {0,3,9},
            {2,1,0}
        };


        double[] ball=powerMiniball(pts);

        System.out.println(
            "center = ("+
            ball[0]+","+ball[1]+")");

        System.out.println(
            "power radius² = "+ball[2]);
    }
}
