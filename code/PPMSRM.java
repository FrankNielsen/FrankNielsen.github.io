// Frank.Nielsen@acm.org 
// (c) Frank Nielsen 2003

import java.io.*;
import java.util.*;

/*
 see:
 
 Nielsen, Frank, and Richard Nock. "On region merging: The statistical soundness of fast sorting, with applications."
 IEEE Computer Society Conference on Computer Vision and Pattern Recognition, 2003. 
 
 Nock, Richard, and Frank Nielsen. "Statistical region merging." 
 IEEE Transactions on pattern analysis and machine intelligence 26.11 (2004): 1452-1458.
 */

class testSRM{
	
	public static void main(String [] args)
	{System.out.println("PPM SRM statistical region merging. (c) Frank Nielsen 2003");
	
	PPM img=new PPM();
	img.read("rings.ppm");
	 
	int dim=img.width*img.height;
	
	int [] rasterin=new int[dim];
		int [] rasterout=new int[dim];
	int n=0;
	int i,j;
	for(i=0;i<img.height;i++)
		for(j=0;j<img.width;j++)
		{rasterin[n]= ((img.r[i][j]&0x0ff)<<16)|((img.g[i][j]&0x0ff)<<8)|(img.b[i][j]&0x0ff);
			n++;
		}
	
 
	
SRM	srm=new SRM(img.width,img.height);

srm.Q=32;

	srm.segmentImg(rasterin,rasterout);
		
		int index=0;
			for(i=0;i<img.height;i++)
		for(j=0;j<img.width;j++)
		{ img.r[i][j]=rasterout[index] & 0xFF;
	img.g[i][j]= ((rasterout[index] & 0xFF00) >> 8) ;
	img.b[i][j]=((rasterout[index] & 0xFF0000) >> 16);
			index++;
		}
	 
	 img.write("Segmented-"+srm.Q+".ppm");
	 
	 
	}
}

class SRM {
        // Input/Output image
//        Image img, imgseg;

        private int[] raster;
        private int[] rastero;
        private int w, h, n;
        private double aspectratio;

        public double Q=32;
        private UnionFind UF;
        private double g; // number of levels in a color channel
        private double logdelta;

        // Auxilliary buffers for union-find operations
        private int[] N;
        private double[] Ravg;
        private double[] Gavg;
        private double[] Bavg;
        private int[] C; // the class number

        // number of pixels that define a "small region" to be collapsed
        private int smallregion;
        private int borderthickness;
        
        SRM(int width,int height)
        {
           g = 256.0;
                borderthickness = 0; // border thickness of regions
                       w = width ; h = height ;
                aspectratio = (double) h / (double) w;
                n = w * h;
                
                
                Ravg = new double[n];
                Gavg = new double[n];
                Bavg = new double[n];
                N = new int[n];
                C = new int[n]; 
               
         
                logdelta = 2.0 * Math.log(6.0 * n);
                // small regions are less than 0.1% of image pixels
                smallregion = (int) (0.001 * n); 
        }
        
       

        public void segmentImg(int[] imgBytes,  int[] outImg) {
              //  Q = 32;
              

           UF = new UnionFind(n);
                raster = imgBytes ;
                // One round of segmentation
                rastero = outImg ;

                OneRound();
        }


        private void OneRound() {
              /*
            
              UF = new UnionFind(n);
                Ravg = new double[n];
                Gavg = new double[n];
                Bavg = new double[n];
                N = new int[n];
                C = new int[n];
                
                */
                //rastero = new int[n];

                InitializeSegmentation();
                FullSegmentation();
        }

        private void InitializeSegmentation() {
                //
                // Initialization
                //
                int x, y, xred, xgreen, xblue, index;
                for (y = 0; y < h; y++) {
                        for (x = 0; x < w; x++) {
                                index = y * w + x;

                                xred = (raster[y * w + x] & 0xFF);
                                xgreen = ((raster[y * w + x] & 0xFF00) >> 8);
                                xblue = ((raster[y * w + x] & 0xFF0000) >> 16);

                                Ravg[index] = xred;
                                Gavg[index] = xgreen;
                                Bavg[index] = xblue;
                                N[index] = 1;
                                C[index] = index;
                        }
                }
        }

        private void FullSegmentation() {
                Segmentation();
            //    MergeSmallRegion();
                OutputSegmentation();
                DrawBorder();
        }


        private double max3(double a, double b, double c) {
                return Math.max(a, Math.max(b, c));
        }

        private boolean MergePredicate(int reg1, int reg2) {
                double dR, dG, dB;
                double logreg1, logreg2;
                double dev1, dev2, dev;

                dR = (Ravg[reg1] - Ravg[reg2]);
                dR *= dR;

                dG = (Gavg[reg1] - Gavg[reg2]);
                dG *= dG;

                dB = (Bavg[reg1] - Bavg[reg2]);
                dB *= dB;

                logreg1 = Math.min(g, N[reg1]) * Math.log(1.0 + N[reg1]);
                logreg2 = Math.min(g, N[reg2]) * Math.log(1.0 + N[reg2]);

                dev1 = ((g * g) / (2.0 * Q * N[reg1])) * (logreg1 + logdelta);
                dev2 = ((g * g) / (2.0 * Q * N[reg2])) * (logreg2 + logdelta);

                dev = dev1 + dev2;

                return ((dR < dev) && (dG < dev) && (dB < dev));
        }

        private Rmpair[] BucketSort(Rmpair[] a, int n) {
                int i;
                int[] nbe;
                int[] cnbe;
                Rmpair[] b;

                nbe = new int[256];
                cnbe = new int[256];

                b = new Rmpair[n];

                for (i = 0; i < 256; i++)
                        nbe[i] = 0;
                // class all elements according to their family
                for (i = 0; i < n; i++)
                        nbe[a[i].diff]++;
                // cumulative histogram
                cnbe[0] = 0;
                for (i = 1; i < 256; i++)
                        cnbe[i] = cnbe[i - 1] + nbe[i - 1]; // index of first element of
                                                                                                // category i

                // allocation
                for (i = 0; i < n; i++) {
                        b[cnbe[a[i].diff]++] = a[i];
                }

                return b;
        }

        //
        // Merge two regions
        //
        private void MergeRegions(int C1, int C2) {
                int reg, nreg;
                double ravg, gavg, bavg;

                reg = UF.UnionRoot(C1, C2);

                nreg = N[C1] + N[C2];
                ravg = (N[C1] * Ravg[C1] + N[C2] * Ravg[C2]) / nreg;
                gavg = (N[C1] * Gavg[C1] + N[C2] * Gavg[C2]) / nreg;
                bavg = (N[C1] * Bavg[C1] + N[C2] * Bavg[C2]) / nreg;

                N[reg] = nreg;

                Ravg[reg] = ravg;
                Gavg[reg] = gavg;
                Bavg[reg] = bavg;
        }

        //
        // Main segmentation procedure here
        //
        private void Segmentation() {
                int i, j, index;
                int reg1, reg2;
                Rmpair[] order;
                int npair;
                int cpair = 0;
                int C1, C2;
                int r1, g1, b1;
                int r2, g2, b2;

                // Consider C4-connectivity here
                npair = 2 * (w - 1) * (h - 1) + (h - 1) + (w - 1);
                order = new Rmpair[npair];

            //    System.out.println("Building the initial image RAG (" + npair
            //                   + " edges)");

                for (i = 0; i < h - 1; i++) {
                        for (j = 0; j < w - 1; j++) {
                                index = i * w + j;

                                // C4 left
                                order[cpair] = new Rmpair();
                                order[cpair].r1 = index;
                                order[cpair].r2 = index + 1;

                                r1 = raster[index] & 0xFF;
                                g1 = ((raster[index] & 0xFF00) >> 8);
                                b1 = ((raster[index] & 0xFF0000) >> 16);

                                r2 = raster[index + 1] & 0xFF;
                                g2 = ((raster[index + 1] & 0xFF00) >> 8);
                                b2 = ((raster[index + 1] & 0xFF0000) >> 16);

                                order[cpair].diff = (int) max3(Math.abs(r2 - r1),
                                                Math.abs(g2 - g1), Math.abs(b2 - b1));
                                cpair++;

                                // C4 below
                                order[cpair] = new Rmpair();
                                order[cpair].r1 = index;
                                order[cpair].r2 = index + w;

                                r2 = raster[index + w] & 0xFF;
                                g2 = ((raster[index + w] & 0xFF00) >> 8);
                                b2 = ((raster[index + w] & 0xFF0000) >> 16);

                                order[cpair].diff = (int) max3(Math.abs(r2 - r1),
                                                Math.abs(g2 - g1), Math.abs(b2 - b1));
                                cpair++;
                        }
                }

                //
                // The two border lines
                //
                for (i = 0; i < h - 1; i++) {
                        index = i * w + w - 1;
                        order[cpair] = new Rmpair();
                        order[cpair].r1 = index;
                        order[cpair].r2 = index + w;

                        r1 = raster[index] & 0xFF;
                        g1 = ((raster[index] & 0xFF00) >> 8);
                        b1 = ((raster[index] & 0xFF0000) >> 16);
                        r2 = raster[index + w] & 0xFF;
                        g2 = ((raster[index + w] & 0xFF00) >> 8);
                        b2 = ((raster[index + w] & 0xFF0000) >> 16);
                        order[cpair].diff = (int) max3(Math.abs(r2 - r1),
                                        Math.abs(g2 - g1), Math.abs(b2 - b1));
                        cpair++;
                }

                for (j = 0; j < w - 1; j++) {
                        index = (h - 1) * w + j;

                        order[cpair] = new Rmpair();
                        order[cpair].r1 = index;
                        order[cpair].r2 = index + 1;

                        r1 = raster[index] & 0xFF;
                        g1 = ((raster[index] & 0xFF00) >> 8);
                        b1 = ((raster[index] & 0xFF0000) >> 16);
                        r2 = raster[index + 1] & 0xFF;
                        g2 = ((raster[index + 1] & 0xFF00) >> 8);
                        b2 = ((raster[index + 1] & 0xFF0000) >> 16);
                        order[cpair].diff = (int) max3(Math.abs(r2 - r1),
                                        Math.abs(g2 - g1), Math.abs(b2 - b1));

                        cpair++;
                }

                //
                // Sort the edges according to the maximum color channel difference
                //
                order = BucketSort(order, npair);

                // Main algorithm is here!!!
            //    System.out.println("Testing the merging predicate in a single loop");

                for (i = 0; i < npair; i++) {
                        reg1 = order[i].r1;
                        C1 = UF.Find(reg1);
                        reg2 = order[i].r2;
                        C2 = UF.Find(reg2);
                        if ((C1 != C2) && (MergePredicate(C1, C2)))
                                MergeRegions(C1, C2);
                }

        }

        //
        // Output the segmentation: Average color for each region
        //
        private void OutputSegmentation() {
                int i, j, index, indexb;
                int r, g, b, a, rgba;

                index = 0;

                for (i = 0; i < h; i++)
                        // for each row
                        for (j = 0; j < w; j++) // for each column
                        {
                                index = i * w + j;
                                indexb = UF.Find(index); // Get the root index

                                //
                                // average color choice in this demo
                                //
                                r = (int) Ravg[indexb];
                                g = (int) Gavg[indexb];
                                b = (int) Bavg[indexb];

                                rgba = (0xff000000 | b << 16 | g << 8 | r);

                                rastero[index] = rgba;
                        }
        }

        //
        // Merge small regions
        //
        private void MergeSmallRegion() {
                int i, j, C1, C2, index;

                index = 0;

                for (i = 0; i < h; i++)
                        // for each row
                        for (j = 1; j < w; j++) // for each column
                        {
                                index = i * w + j;
                                C1 = UF.Find(index);
                                C2 = UF.Find(index - 1);
                                if (C2 != C1) {
                                        if ((N[C2] < smallregion) || (N[C1] < smallregion))
                                                MergeRegions(C1, C2);
                                }
                        }
        }

        // Draw white borders delimiting perceptual regions
        private void DrawBorder() {
                int i, j, k, l, C1, C2, reg, index;

                for (i = 1; i < h; i++)
                        // for each row
                        for (j = 1; j < w; j++) // for each column
                        {
                                index = i * w + j;

                                C1 = UF.Find(index);
                                C2 = UF.Find(index - 1 - w);

                                if (C2 != C1) {
                                        for (k = -borderthickness; k <= borderthickness; k++)
                                                for (l = -borderthickness; l <= borderthickness; l++) {
                                                        index = (i + k) * w + (j + l);
                                                        if ((index >= 0) && (index < w * h)) {

                                                                rastero[index] = (0xff000000 | 255 << 16
                                                                                | 255 << 8 | 255);
                                                        }
                                                }
                                }
                        }
        }

        //
        // Union Find Data Structure of Tarjan for Disjoint Sets
        //
        class UnionFind {
                private int[] rank;
                private int[] parent;
                //
                // Create a UF for n elements
                //
                public UnionFind(int n) {
                        int k;
        
                        parent = new int[n];
                        rank = new int[n];
        
                    //    System.out.println("Creating a UF DS for " + n + " elements");
        
                        for (k = 0; k < n; k++) {
                                parent[k] = k;
                                rank[k] = 0;
                        }
                }
                public int Find(int k) {
                        while (parent[k] != k)
                                k = parent[k];
                        return k;
                }
        
                //
                // Assume x and y being roots
                //
                public int UnionRoot(int x, int y) {
                        if (x == y)
                                return -1;
        
                        if (rank[x] > rank[y]) {
                                parent[y] = x;
                                return x;
                        } else {
                                parent[x] = y;
                                if (rank[x] == rank[y])
                                        rank[y]++;
                                return y;
                        }
                }
        }

        // An edge: two indices and a difference value
        private class Rmpair { int r1=0, r2=0 , diff=0;}

}
 class PPM
{
    public int [][] r; // Red channel
    public int [][] g; // Green channel
    public int [][] b; // Blue channel
    public int depth,width,height;

    public PPM()
    {depth=255;  width = height = 0;}

    public PPM(int Width, int Height)
    {
        depth = 255; 
        width = Width;
        height = Height;
        r = new int[height][width];
        g = new int[height][width];
        b = new int[height][width];
    }

    public void read(String fileName)
    {
        String line;
        StringTokenizer st;
        int i;

        try {
            DataInputStream in = new DataInputStream(new BufferedInputStream(new FileInputStream(fileName)));
            in.readLine();
            do {
                line = in.readLine();
            } while (line.charAt(0) == '#');

            st = new StringTokenizer(line);
            width = Integer.parseInt(st.nextToken());
            height = Integer.parseInt(st.nextToken());
			r = new int[height][width];
        	g = new int[height][width];
        	b = new int[height][width];
            line = in.readLine();
            st = new StringTokenizer(line);
            depth = Integer.parseInt(st.nextToken());

            for (int y = 0; y < height; y++) {
                for (int x = 0; x < width; x++) {
					r[y][x] = in.readUnsignedByte();
					g[y][x] = in.readUnsignedByte();
					b[y][x] = in.readUnsignedByte();
				}
			}
            in.close();
        } catch(IOException e) {}
    }

    public void write(String filename)
    {
        String line;
        StringTokenizer st;
        int i;
        try {
            DataOutputStream out =new DataOutputStream(new BufferedOutputStream(new FileOutputStream(filename)));
            out.writeBytes("P6\n");
            out.writeBytes("# Frank Nielsen\n");
            out.writeBytes(width+" "+height+"\n255\n");

			for (int y = 0; y < height; y++) {
				for (int x = 0; x < width; x++) {
					out.writeByte((byte)r[y][x]);
					out.writeByte((byte)g[y][x]);
					out.writeByte((byte)b[y][x]);
				}
			}
            out.close();
        } catch(IOException e) {}
    }
}
// End of simple PPM library
