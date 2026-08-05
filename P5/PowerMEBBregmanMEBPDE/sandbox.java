class sandbox{


static void Test(){double[] c = {0.0, 0.0};
double r = 2.0;
double[] p = {5.0, 3.0};

double[] q1 = tangentPoint(c, r, p, +1);
double[] q2 = tangentPoint(c, r, p, -1);

System.out.printf("q1=(%.6f, %.6f)%n", q1[0], q1[1]);
System.out.printf("q2=(%.6f, %.6f)%n", q2[0], q2[1]);
}
 public static double[] tangentPoint(
        double[] c,
        double r,
        double[] p,
        int side) {

    double dx = p[0] - c[0];
    double dy = p[1] - c[1];

    double d2 = dx*dx + dy*dy;

    if (d2 <= r*r)
        return null;   // point is inside/on disk

    double factor1 = r*r / d2;
    double factor2 = side * r * Math.sqrt(d2 - r*r) / d2;

    // perpendicular vector to (dx,dy)
    double px = -dy;
    double py = dx;

    double qx = c[0] + factor1*dx + factor2*px;
    double qy = c[1] + factor1*dy + factor2*py;

    return new double[]{qx, qy};
}


}
