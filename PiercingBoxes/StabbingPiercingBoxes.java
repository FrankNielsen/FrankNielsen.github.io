// (C) 1997-1998, revised June 2014 by Frank Nielsen  (Frank.Nie...@acm.org  5793b870)
//
// Compile with: javac StabbingPiercingBoxes.java   (if javac complains use option -source 1.4  -Xlint:deprecation -Xlint:unchecked)
// Run with: appletviewer run.html
// where run.html contains this code:
// <APPLET CODE="StabbingPiercingBoxes.class" WIDTH=950 HEIGHT=500 ALIGN=CENTER></APPLET>

// Left-click drag for adding a box or select from menu for adding many boxes
// originally, those files were called boxes.java, IntervalSet.java, etc.

/*
Divide and conquer paradigm for approximation:

Fast stabbing of boxes in high dimensions. 
Frank Nielsen
Theoretical Computer Science 246(1-2): 53-72 (2000)

http://www.sciencedirect.com/science/article/pii/S0304397598003363

@Article{n-fsbhd-2000,
 author = {Frank Nielsen},
 title = {Fast stabbing of boxes in high dimensions},
 journal = {Theoretical Computer Science},
 volume = {246},
 number = {1/2},
 year = {2000},
 issn = {0304-3975},
 pages = {53--75},
 publisher = {Elsevier Science Publishers Ltd.},
 doi= {10.1016/S0304-3975(98)00336-3}
 }
 

On point covers of c-oriented polygons. 
Frank Nielsen
Theoretical Computer Science  263(1-2): 17-29 (2001)

see CCCG 1996 and also


Maintenance of a Piercing Set for Intervals with Applications. 
Matthew J. Katz, Frank Nielsen, Michael Segal
Algorithmica 36(1): 59-73 (2003)


The heuristics compute in output-sensitive time an approximation of :
- a maximum independent set of rectangles  (axis-parallel also called isothetic d-dimensional boxes, independent set into k pairwise non-connected vertices)
- a minimum clique cover of rectangles (vertices of a graph can be partitioned into k cliques)
without computing the intersection graph (that would require quadratic time)

*/

import java.applet.Applet;
import java.awt.*;
import java.io.PrintStream;
import java.util.Random;
import java.util.Vector;

public class StabbingPiercingBoxes extends Applet
{

    public StabbingPiercingBoxes()
    {
        ABOUT = 0;
    }

    public void Animation(Graphics g)
    {
        clear(g);
        g.drawString("Piercing Isothetic Boxes / Giving an Independent Set", 200, 100);
        g.drawString("Nielsen Frank, Frank.Nielsen@acm.org", 260, 115);
        g.drawString("An output-sensitive precision-sensitive algorithm", 200, 140);
        g.drawString("DOES NOT COMPUTE THE INCIDENCE/INTERSECTION GRAPH", 200, 160);
        g.drawString("See http://www.sonycsl.co.jp", 200, 180);
        ABOUT++;
    }

    public boolean action(Event event, Object obj)
    {
        if(event.target == reset)
        {
            Graphics g = getGraphics();
            Rectangle rectangle = getBounds();
            g.setColor(getBackground());
            g.fillRect(rectangle.x, rectangle.y, rectangle.width, rectangle.height);
            nbboxes = 0;
            VRect.setSize(0);
            return true;
        }
        if(event.target == pierce)
        {
            if(nbboxes != 0)
            {
                Pierce pierce1 = new Pierce(VRect);
                if(salg == 1)
                    pierce1.Alg1();
                if(salg == 2)
                    pierce1.Alg2();
                System.out.println("#Piercing points :" + pierce1.VPoints.size() + " on " + pierce1.size() + " Rectangles.(" + salg + ")");
                System.out.println("   Independent set of size:" + pierce1.VIRectangles.size());
                VPPoints = pierce1.VPoints;
                VIRect = pierce1.VIRectangles;
                Graphics g1 = getGraphics();
                Rectangle rectangle1 = getBounds();
                g1.setColor(getBackground());
                g1.fillRect(rectangle1.x, rectangle1.y, rectangle1.width, rectangle1.height);
                g1.setColor(Color.black);
                paint(g1);
            }
        } else
        if(event.target == about)
            Animation(getGraphics());
        else
        if(event.target == random)
        {
            Random random1 = new Random();
            char c = '\n';
            if(obj.equals("20 rectangles"))
                c = '\024';
            if(obj.equals("50 rectangles"))
                c = '2';
            if(obj.equals("100 rectangles"))
                c = 'd';
            if(obj.equals("200 rectangles"))
                c = '\310';
            if(obj.equals("500 rectangles"))
                c = '\u01F4';
            if(obj.equals("1000 rectangles"))
                c = '\u03E8';
            if(obj.equals("10000 rectangles"))
                c = '\u2710';
            Vector vector = new Vector(c);
            VRect.setSize(0);
            for(int i = 0; i < c; i++)
            {
                int j = random1.nextInt() % WIDTH;
                int k = random1.nextInt() % HEIGHT;
                int l = random1.nextInt() % WIDTH;
                int i1 = random1.nextInt() % HEIGHT;
                if(j < 0)
                    j = -j;
                if(k < 0)
                    k = -k;
                if(l < 0)
                    l = -l;
                if(i1 < 0)
                    i1 = -i1;
                if(j > l)
                {
                    int j1 = j;
                    j = l;
                    l = j1;
                }
                if(k > i1)
                {
                    int k1 = k;
                    k = i1;
                    i1 = k1;
                }
                Rectangle rectangle3 = new Rectangle(j, k, l - j, i1 - k);
                VRect.addElement(rectangle3);
                vector.addElement(rectangle3);
            }

            Pierce pierce3 = new Pierce(vector);
            if(salg == 1)
                pierce3.Alg1();
            if(salg == 2)
                pierce3.Alg2();
            VPPoints = pierce3.VPoints;
            VIRect = pierce3.VIRectangles;
            System.out.println("#Piercing points :" + pierce3.VPoints.size() + " on " + pierce3.size() + " Rectangles.(" + salg + ")");
            System.out.println("   Independent set of size:" + VIRect.size());
            clear(getGraphics());
            paint(getGraphics());
        } else
        if(event.target == selectalg)
        {
            if(obj.equals("Heuristic 1, 1996"))
                salg = 1;
            if(obj.equals("Heuristic 2, 1997"))
                salg = 2;
            Pierce pierce2 = new Pierce(VRect);
            if(salg == 1)
                pierce2.Alg1();
            if(salg == 2)
                pierce2.Alg2();
            VPPoints = pierce2.VPoints;
            VIRect = pierce2.VIRectangles;
            System.out.println("#Piercing points :" + pierce2.VPoints.size() + " on " + pierce2.size() + " Rectangles.(" + salg + ")");
            System.out.println("   Independent set of size:" + VIRect.size());
            Graphics g2 = getGraphics();
            Rectangle rectangle2 = getBounds();
            g2.setColor(getBackground());
            g2.fillRect(rectangle2.x, rectangle2.y, rectangle2.width, rectangle2.height);
            g2.setColor(Color.black);
            paint(g2);
        } else
        {
            return super.action(event, obj);
        }
        return true;
    }

    public void clear(Graphics g)
    {
        Rectangle rectangle = getBounds();
        g.setColor(getBackground());
        g.fillRect(rectangle.x, rectangle.y, rectangle.width, rectangle.height);
        g.setColor(Color.black);
    }

    public void init()
    {
        System.out.println("Welcome to the piercing java program.\n(C) Frank Nielsen 1997 1998 v1.1\nSony Computer Science Laboratories and Ecole Polytechnique");
        nbboxes = 0;
        WIDTH = 800;
        HEIGHT = 500;
        VRect = new Vector(20);
        VPPoints = new Vector(20);
        VIRect = new Vector(20);
        setBackground(Color.white);
        setForeground(Color.black);
        reset = new Button("Reset");
        pierce = new Button("Pierce");
        about = new Button("About");
        add(reset);
        add(pierce);
        add(about);
        random = new Choice();
        random.addItem("20 rectangles");
        random.addItem("50 rectangles");
        random.addItem("100 rectangles");
        random.addItem("200 rectangles");
        random.addItem("500 rectangles");
        random.addItem("1000 rectangles");
        random.addItem("10000 rectangles");
        add(new Label("Random:"));
        add(random);
        salg = 1;
        selectalg = new Choice();
        selectalg.addItem("Heuristic 1, 1996");
        selectalg.addItem("Heuristic 2, 1997");
        add(new Label("Heuristics:"));
        add(selectalg);
    }

    public boolean mouseDown(Event event, int i, int j)
    {
        x1 = i;
        y1 = j;
        Xp = x1;
        Yp = y1;
        DXp = 0;
        DYp = 0;
        return true;
    }

    public boolean mouseDrag(Event event, int i, int j)
    {
        x2 = i;
        y2 = j;
        int k = x1;
        int l = y1;
        if(x1 > x2)
        {
            int i2 = x1;
            k = x2;
            x2 = i2;
        }
        if(y1 > y2)
        {
            int j2 = y1;
            l = y2;
            y2 = j2;
        }
        int i1 = k;
        int j1 = l;
        int k1 = x2 - k;
        int l1 = y2 - l;
        Graphics g = getGraphics();
        g.setXORMode(Color.white);
        g.setColor(Color.blue);
        g.drawRect(Xp, Yp, DXp, DYp);
        Xp = i1;
        Yp = j1;
        DXp = k1;
        DYp = l1;
        g.setColor(Color.blue);
        g.drawRect(i1, j1, k1, l1);
        return true;
    }

    public boolean mouseEnter(Event event, int i, int j)
    {
        showStatus("[" + i + "," + j + "]");
        return true;
    }

    public boolean mouseMove(Event event, int i, int j)
    {
        showStatus("[" + i + "," + j + "]");
        return true;
    }

    public boolean mouseUp(Event event, int i, int j)
    {
        int k = x1;
        int l = y1;
        x2 = i;
        y2 = j;
        nbboxes++;
        if(x1 > x2)
        {
            int i1 = x1;
            k = x2;
            x2 = i1;
        }
        if(y1 > y2)
        {
            int j1 = y1;
            l = y2;
            y2 = j1;
        }
        Xp = k;
        Yp = l;
        DXp = x2 - k;
        DYp = y2 - l;
        Graphics g = getGraphics();
        g.drawRect(Xp, Yp, DXp, DYp);
        Rectangle rectangle = new Rectangle(Xp, Yp, DXp, DYp);
        VRect.addElement(rectangle);
        return true;
    }

    public void paint(Graphics g)
    {
        if(ABOUT == 1)
        {
            Animation(getGraphics());
            return;
        }
        g.setColor(Color.green);
        int l = VIRect.size();
        for(int i = 0; i < l; i++)
        {
            Rectangle rectangle = (Rectangle)VIRect.elementAt(i);
            g.fillRect(rectangle.x, rectangle.y, rectangle.width, rectangle.height);
        }

        g.setColor(Color.black);
        l = VRect.size();
        byte byte0 = 5;
        for(int j = 0; j < l; j++)
        {
            Rectangle rectangle1 = (Rectangle)VRect.elementAt(j);
            g.drawRect(rectangle1.x, rectangle1.y, rectangle1.width, rectangle1.height);
        }

        l = VPPoints.size();
        g.setColor(Color.red);
        for(int k = 0; k < l; k++)
        {
            Point point = (Point)VPPoints.elementAt(k);
            g.fillRect(point.x - 3, point.y - 3, 6, 6);
        }

        g.setColor(Color.black);
    }

    private Button reset;
    private Button pierce;
    private Button about;
    private Choice random;
    private Choice selectalg;
    private int x1;
    private int y1;
    private int x2;
    private int y2;
    private int Xp;
    private int Yp;
    private int DXp;
    private int DYp;
    private int nbboxes;
    private Vector VRect;
    private Vector VPPoints;
    private Vector VIRect;
    private int WIDTH;
    private int HEIGHT;
    private int salg;
    private int ABOUT;
}


class About extends Dialog
{

    public About(Frame frame, String s, String s1)
    {
        super(frame, s, false);
        setLayout(new BorderLayout(15, 15));
        label = new Label(s1);
        add("Center", label);
        ok = new Button("Close");
        Panel panel = new Panel();
        panel.setLayout(new FlowLayout(1, 15, 15));
        panel.add(ok);
        add("South", panel);
        pack();
    }

    public boolean action(Event event, Object obj)
    {
        if(event.target == ok)
        {
            hide();
            dispose();
            return true;
        } else
        {
            return false;
        }
    }

    protected Button ok;
    protected Label label;
}

class IntervalSet
{

    public IntervalSet(int i, int ai[], int ai1[], int j)
    {
        n = i;
        x = new int[n];
        y = new int[n];
        for(int k = 0; k < i; k++)
        {
            x[k] = ai[k];
            y[k] = ai1[k];
        }

        VPoints = new Vector(0);
        VIindex = new Vector(0);
        Xmed = j;
    }

    public IntervalSet(int i, Rectangle arectangle[], int j)
    {
        n = i;
        x = new int[n];
        y = new int[n];
        for(int k = 0; k < i; k++)
        {
            x[k] = arectangle[k].x;
            y[k] = arectangle[k].x + arectangle[k].height;
        }

        VPoints = new Vector(0);
        VIindex = new Vector(0);
        Xmed = j;
    }

    public void Pierce()
    {
        int ai[] = new int[n];
        int l = 0;
        for(int i = 0; i < n; i++)
            ai[i] = 0;

        while(l < n) 
        {
            int i1 = 0;
            int j1 = 0;
            for(int j = 0; j < n; j++)
                if(x[j] >= i1 && ai[j] == 0)
                {
                    i1 = x[j];
                    j1 = j;
                }

            Point point = new Point(Xmed, i1);
            Point point1 = new Point(j1, j1);
            VPoints.addElement(point);
            VIindex.addElement(point1);
            for(int k = 0; k < n; k++)
                if(ai[k] == 0 && x[k] <= i1 && y[k] >= i1)
                {
                    l++;
                    ai[k] = 1;
                }

        }
    }

    private int n;
    private int Xmed;
    private int x[];
    private int y[];
    public Vector VPoints;
    public Vector VIindex;
}

class Pierce
{

    public Pierce(Vector vector)
    {
        n = vector.size();
        x = new int[2 * n];
        y = new int[2 * n];
        for(int i = 0; i < n; i++)
        {
            Rectangle rectangle = (Rectangle)vector.elementAt(i);
            x[i] = rectangle.x;
            y[i] = rectangle.y;
            x[i + n] = x[i] + rectangle.width;
            y[n + i] = y[i] + rectangle.height;
        }

        VPoints = new Vector(5);
        VIRectangles = new Vector(5);
    }

    public void Alg1()
    {
        Statistic statistic = new Statistic(2 * n, x);
        int i2 = statistic.Median(n);
        int k1;
        int l1;
        int j1 = k1 = l1 = 0;
        for(int i = 0; i < n; i++)
            if(x[i] <= i2 && x[n + i] >= i2)
                l1++;
            else
            if(x[i] < i2)
                j1++;
            else
                k1++;

        int ai[] = new int[l1];
        int ai1[] = new int[l1];
        Vector vector = new Vector(j1);
        Vector vector1 = new Vector(k1);
        l1 = 0;
        for(int j = 0; j < n; j++)
            if(x[j] <= i2 && x[n + j] >= i2)
            {
                ai[l1] = y[j];
                ai1[l1++] = y[n + j];
            } else
            {
                Rectangle rectangle = new Rectangle(x[j], y[j], x[j + n] - x[j], y[j + n] - y[j]);
                if(x[j] < i2)
                    vector.addElement(rectangle);
                else
                    vector1.addElement(rectangle);
            }

        if(l1 > 0)
        {
            IntervalSet intervalset = new IntervalSet(l1, ai, ai1, i2);
            intervalset.Pierce();
            for(int k = 0; k < intervalset.VPoints.size(); k++)
                VPoints.addElement(intervalset.VPoints.elementAt(k));

        }
        if(j1 > 0)
        {
            Pierce pierce = new Pierce(vector);
            pierce.Alg1();
            for(int l = 0; l < pierce.VPoints.size(); l++)
                VPoints.addElement(pierce.VPoints.elementAt(l));

        }
        if(k1 > 0)
        {
            Pierce pierce1 = new Pierce(vector1);
            pierce1.Alg1();
            for(int i1 = 0; i1 < pierce1.VPoints.size(); i1++)
                VPoints.addElement(pierce1.VPoints.elementAt(i1));

        }
    }

    public void Alg2()
    {
        int ai[] = new int[n];
        int ai1[] = new int[n];
        for(int i = 0; i < n; i++)
        {
            ai[i] = x[i];
            ai1[i] = x[i + n];
        }

        IntervalSet intervalset = new IntervalSet(n, ai, ai1, 0);
        intervalset.Pierce();
        int l3 = ((Point)intervalset.VPoints.elementAt(intervalset.VPoints.size() / 2)).y;
        int k2;
        int l2;
        int j2 = k2 = l2 = 0;
        int j3;
        int k3;
        int i3 = j3 = k3 = 0;
        for(int j = 0; j < n; j++)
            if(x[j] <= l3 && x[n + j] >= l3)
                l2++;
            else
            if(x[j] < l3)
                j2++;
            else
                k2++;

        Rectangle arectangle[] = new Rectangle[l2];
        Vector vector = new Vector(j2);
        Vector vector1 = new Vector(k2);
        l2 = 0;
        for(int k = 0; k < n; k++)
            if(x[k] <= l3 && x[n + k] >= l3)
            {
                arectangle[l2] = new Rectangle(x[k], y[k], x[k + n] - x[k], y[k + n] - y[k]);
                l2++;
            } else
            {
                Rectangle rectangle = new Rectangle(x[k], y[k], x[k + n] - x[k], y[k + n] - y[k]);
                if(x[k] < l3)
                    vector.addElement(rectangle);
                else
                    vector1.addElement(rectangle);
            }

        Rectangle1D rectangle1d = new Rectangle1D(l2, arectangle, l3);
        if(l2 > 0)
        {
            rectangle1d.Pierce();
            for(int l = 0; l < rectangle1d.VPoints.size(); l++)
                VPoints.addElement(rectangle1d.VPoints.elementAt(l));

            k3 = rectangle1d.VIRectangles.size();
        }
        Pierce pierce = new Pierce(vector);
        if(j2 > 0)
        {
            pierce.Alg2();
            i3 = pierce.VIRectangles.size();
            for(int i1 = 0; i1 < pierce.VPoints.size(); i1++)
                VPoints.addElement(pierce.VPoints.elementAt(i1));

        }
        Pierce pierce1 = new Pierce(vector1);
        if(k2 > 0)
        {
            pierce1.Alg2();
            j3 = pierce1.VIRectangles.size();
            for(int j1 = 0; j1 < pierce1.VPoints.size(); j1++)
                VPoints.addElement(pierce1.VPoints.elementAt(j1));

        }
        if(i3 + j3 <= k3)
        {
            for(int k1 = 0; k1 < k3; k1++)
                VIRectangles.addElement(rectangle1d.VIRectangles.elementAt(k1));

        } else
        {
            for(int l1 = 0; l1 < i3; l1++)
                VIRectangles.addElement(pierce.VIRectangles.elementAt(l1));

            for(int i2 = 0; i2 < j3; i2++)
                VIRectangles.addElement(pierce1.VIRectangles.elementAt(i2));

        }
    }

    public int size()
    {
        return n;
    }

    private int n;
    private int x[];
    private int y[];
    public Vector VPoints;
    public Vector VIRectangles;
}

 class Rectangle1D
{

    public Rectangle1D(int i, Rectangle arectangle[], int j)
    {
        n = i;
        R = new Rectangle[i];
        for(int k = 0; k < i; k++)
            R[k] = arectangle[k];

        VPoints = new Vector(0);
        VIRectangles = new Vector(0);
        Xmed = j;
    }

    public void Pierce()
    {
        int j1 = -1;
        int ai[] = new int[n];
        int l = 0;
        for(int i = 0; i < n; i++)
            ai[i] = 0;

        while(l < n) 
        {
            int i1 = 0;
            for(int j = 0; j < n; j++)
                if(R[j].y >= i1 && ai[j] == 0)
                {
                    i1 = R[j].y;
                    j1 = j;
                }

            Point point = new Point(Xmed, i1);
            Rectangle rectangle = new Rectangle(R[j1].x, R[j1].y, R[j1].width, R[j1].height);
            VPoints.addElement(point);
            VIRectangles.addElement(rectangle);
            for(int k = 0; k < n; k++)
                if(ai[k] == 0 && R[k].y <= i1 && R[k].y + R[k].height >= i1)
                {
                    l++;
                    ai[k] = 1;
                }

        }
    }

    private int n;
    private int Xmed;
    private Rectangle R[];
    public Vector VPoints;
    public Vector VIRectangles;
}


class Statistic
{

    public Statistic(int i, int ai[])
    {
        n = i;
        tab = new int[n];
        for(int j = 0; j < n; j++)
            tab[j] = ai[j];

    }

    public int Median(int i)
    {
        int j = 0;
        if(n == 1)
        {
            j = tab[0];
        } else
        {
            int k = tab[0];
            int k1 = 0;
            int l1 = 0;
            for(int l = 0; l < n; l++)
            {
                if(tab[l] < k)
                    k1++;
                if(tab[l] > k)
                    l1++;
            }

            if(i <= k1)
            {
                int ai[] = new int[k1];
                k1 = 0;
                for(int i1 = 0; i1 < n; i1++)
                    if(tab[i1] < k)
                        ai[k1++] = tab[i1];

                Statistic statistic = new Statistic(k1, ai);
                j = statistic.Median(i);
            }
            if(i > n - l1)
            {
                int ai1[] = new int[l1];
                l1 = 0;
                for(int j1 = 0; j1 < n; j1++)
                    if(tab[j1] > k)
                        ai1[l1++] = tab[j1];

                Statistic statistic1 = new Statistic(l1, ai1);
                j = statistic1.Median((i - n) + l1);
            }
            if(i > k1 && i <= n - l1)
                j = k;
        }
        return j;
    }

    private int tab[];
    private int n;
}
