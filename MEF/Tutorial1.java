package Tutorials;

import java.util.Locale;
import java.util.Vector;

import Tools.KMeans;
import jMEF.*;

public class Tutorial1 {

	
	/**
	 * Converts valid points (>0) to integer.
	 * @param   points  point set in \f$R^d\f$.
	 * @return          a point set in \f$N^d\f$.
	 */
	private static PVector[] checkPoints(PVector[] points){
		// Count how many point are >0
		int n = 0;
		for (int i=0; i<points.length; i++)
			if (points[i].array[0]>0.5)
				n++;
		
		// Convert valid points as integer
		PVector[] new_points = new PVector[n];
		int idx = 0;
		for (int i=0; i<points.length; i++)
			if (points[i].array[0]>0.5){
				PVector p       = new PVector(1);
				p.array[0]      = Math.round( points[i].array[0] );
				new_points[idx] = p;
				idx++;
			}
		return new_points;
	}
	
	
	/**
	 * Compute the NMI.
	 * @param  points  set of points
	 * @param  f       initial mixture model
	 * @param  g       estimated mixture model
	 * @return         NMI
	 */
	private static double NMI(PVector[] points, MixtureModel f, MixtureModel g){
		
		int m = points.length;
		int n = f.size;
		
		double[][] p = new double[n][n];
		
		for (int i=0; i<m; i++){

			int    f_label = 0;
			int    g_label = 0;
			double f_max   = 0;
			double g_max   = 0;
			
			for (int j=0; j<n; j++){
				double f_tmp = f.weight[j] * f.EF.density(points[i], f.param[j]);
				double g_tmp = g.weight[j] * g.EF.density(points[i], g.param[j]);
				if (f_tmp>f_max){
					f_max   = f_tmp;
					f_label = j;
				}
				if (g_tmp>g_max){
					g_max   = g_tmp;
					g_label = j;
				}
			}
			p[f_label][g_label]++;
		}
		
		// Normalization
		for (int i=0; i<n; i++)
			for (int j=0; j<n; j++)
				p[i][j]/=m;
			
		// Computation of marginal densities
		double[] fl = new double[n];
		double[] gl = new double[n];
		for (int i=0; i<n; i++){
			double f_sum = 0;
			double g_sum = 0;
			for (int j=0; j<n; j++){
				f_sum += p[i][j];
				g_sum += p[j][i];
			}
			fl[i] = f_sum;
			gl[i] = g_sum;
		}
		
		// Computation of NMI
		double mi = 0;
		for (int i=0; i<n; i++)
			for (int j=0; j<n; j++)
				if (p[i][j]>0)
					mi += p[i][j] * Math.log( p[i][j] / (fl[i] * gl[j]) );
		double hf = 0;
		double hg = 0;
		for (int i=0; i<n; i++){
			hf += fl[i] * Math.log(fl[i]);
			hg += gl[i] * Math.log(gl[i]);
		}
		double nmi = mi / Math.sqrt(hf*hg);
				
		return nmi;
	}
	
	
	/**
	 * Compute the mixtures from points drawn from a mixture of Gaussian distributions.
	 * @param m  number of points drawn from the mixture.
	 */
	private static double[] testGaussian(int m){
		
		//
		double[] out = new double[3];
		
		// Initial model : Gaussian
		MixtureModel f = new MixtureModel(3);
		f.EF        = new UnivariateGaussianFixedVariance(25);
		f.weight[0] = 1.0/3.0;
		f.weight[1] = 1.0/3.0;
		f.weight[2] = 1.0/3.0;
		PVector p1  = new PVector(1);
		PVector p2  = new PVector(1);
		PVector p3  = new PVector(1);
		p1.array[0] = 10;
		p2.array[0] = 20;
		p3.array[0] = 40;
		f.param[0]  = p1;
		f.param[1]  = p2;
		f.param[2]  = p3;
		
		// Draw points from the mixture
		PVector[] points = f.drawRandomPoints(m);
		points = checkPoints(points);
		
		// K-means
		Vector<PVector>[] clusters = KMeans.run(points, 3);
		
		// Estimation of the mixture of Gaussians
		MixtureModel mog;
		mog    = BregmanSoftClustering.initialize(clusters, new UnivariateGaussianFixedVariance(25));
		mog    = BregmanSoftClustering.run(points, mog);
		out[0] = NMI(points, f, mog);
		
		// Estimation of the mixture of Poisson
		MixtureModel mop;
		mop    = BregmanSoftClustering.initialize(clusters, new Poisson());
		mop    = BregmanSoftClustering.run(points, mop);
		out[1] = NMI(points, f, mop);
		
		// Estimation of the mixture of Poisson
		MixtureModel mob;
		mob    = BregmanSoftClustering.initialize(clusters, new BinomialFixedN(100));
		mob    = BregmanSoftClustering.run(points, mob);
		out[2] = NMI(points, f, mob);

		// Return
		return out;
	}
	
	
	/**
	 * Compute the mixtures from points drawn from a mixture of Poisson distributions.
	 * @param m  number of points drawn from the mixture.
	 */
	private static double[] testPoisson(int m){
		
		//
		double[] out = new double[3];
		
		// Initial model : Poisson
		MixtureModel f = new MixtureModel(3);
		f.EF        = new Poisson();
		f.weight[0] = 1.0/3.0;
		f.weight[1] = 1.0/3.0;
		f.weight[2] = 1.0/3.0;
		PVector p1  = new PVector(1);
		PVector p2  = new PVector(1);
		PVector p3  = new PVector(1);
		p1.array[0] = 10;
		p2.array[0] = 20;
		p3.array[0] = 40;
		f.param[0]  = p1;
		f.param[1]  = p2;
		f.param[2]  = p3;
		
		// Draw points from the mixture
		PVector[] points = f.drawRandomPoints(m);
		points = checkPoints(points);
		
		// K-means
		Vector<PVector>[] clusters = KMeans.run(points, 3);
		
		// Estimation of the mixture of Gaussians
		MixtureModel mog;
		mog    = BregmanSoftClustering.initialize(clusters, new UnivariateGaussianFixedVariance(25));
		mog    = BregmanSoftClustering.run(points, mog);
		out[0] = NMI(points, f, mog);
		
		// Estimation of the mixture of Poisson
		MixtureModel mop;
		mop    = BregmanSoftClustering.initialize(clusters, new Poisson());
		mop    = BregmanSoftClustering.run(points, mop);
		out[1] = NMI(points, f, mop);
		
		// Estimation of the mixture of Poisson
		MixtureModel mob;
		mob    = BregmanSoftClustering.initialize(clusters, new BinomialFixedN(100));
		mob    = BregmanSoftClustering.run(points, mob);
		out[2] = NMI(points, f, mob);

		// Return
		return out;
	}
	
	
	/**
	 * Compute the mixtures from points drawn from a mixture of Binomial distributions.
	 * @param m  number of points drawn from the mixture.
	 */
	private static double[] testBinomial(int m){
		
		// Output vector
		double[] out = new double[3];
		
		// Initial model : Binomial
		MixtureModel f = new MixtureModel(3);
		f.EF        = new BinomialFixedN(100);
		f.weight[0] = 1.0/3.0;
		f.weight[1] = 1.0/3.0;
		f.weight[2] = 1.0/3.0;
		PVector p1  = new PVector(1);
		PVector p2  = new PVector(1);
		PVector p3  = new PVector(1);
		p1.array[0] = 0.1;
		p2.array[0] = 0.2;
		p3.array[0] = 0.4;
		f.param[0]  = p1;
		f.param[1]  = p2;
		f.param[2]  = p3;
		
		// Draw points from the mixture
		PVector[] points = f.drawRandomPoints(m);
		points = checkPoints(points);
		
		// K-means
		Vector<PVector>[] clusters = KMeans.run(points, 3);
		
		// Estimation of the mixture of Gaussians
		MixtureModel mog;
		mog    = BregmanSoftClustering.initialize(clusters, new UnivariateGaussianFixedVariance(25));
		mog    = BregmanSoftClustering.run(points, mog);
		out[0] = NMI(points, f, mog);
		
		// Estimation of the mixture of Poisson
		MixtureModel mop;
		mop    = BregmanSoftClustering.initialize(clusters, new Poisson());
		mop    = BregmanSoftClustering.run(points, mop);
		out[1] = NMI(points, f, mop);
		
		// Estimation of the mixture of Poisson
		MixtureModel mob;
		mob    = BregmanSoftClustering.initialize(clusters, new BinomialFixedN(100));
		mob    = BregmanSoftClustering.run(points, mob);
		out[2] = NMI(points, f, mob);

		// Return
		return out;
	}
	
	
	/**
	 * Main function.
	 * @param args
	 */
	public static void main(String[] args) {
		
		// Display
		String title = "";
		title += "+-------------------------+\n";
		title += "| Bregman soft clustering |\n";
		title += "+-------------------------+\n";
		System.out.print(title);
		
		// Variables
		int m    = 1000;
		int loop = 100;
	
		// NMI arrays
		double[][] NMI_Gaussian = new double[loop][3];
		double[][] NMI_Poisson  = new double[loop][3];
		double[][] NMI_Binomial = new double[loop][3];
		
		// Computation of NMI
		for (int l=0; l<loop; l++){
			NMI_Gaussian[l] = testGaussian(m);
			NMI_Poisson[l]  = testPoisson(m);
			NMI_Binomial[l] = testBinomial(m);
		}
		
		// Mean and variance
		double[][] means = new double[3][3];
		double[][] vars  = new double[3][3];
		for (int i=0; i<3; i++){
			double gm=0, gv=0, pm=0, pv=0, bm=0, bv=0;
			for (int l=0; l<loop; l++){
				double tmpg = NMI_Gaussian[l][i];
				double tmpp = NMI_Poisson[l][i];
				double tmpb = NMI_Binomial[l][i]; 
				gm += tmpg;
				pm += tmpp;
				bm += tmpb; 
				gv += tmpg*tmpg;
				pv += tmpp*tmpp;
				bv += tmpb*tmpb;
			}
			gm /= loop;
			pm /= loop;
			bm /= loop;
			gv  = gv/loop - gm*gm;
			pv  = pv/loop - pm*pm;
			bv  = bv/loop - bm*bm;
			means[0][i] = gm;
			means[1][i] = pm;
			means[2][i] = bm;
			vars[0][i]  = Math.sqrt(gv);
			vars[1][i]  = Math.sqrt(pv);
			vars[2][i]  = Math.sqrt(bv);
		}
		
		// Display
		System.out.printf(Locale.ENGLISH, "            %13s   %13s   %13s\n", "Gaussian", "Poisson", "Binomial");
		System.out.printf(Locale.ENGLISH, "Gaussian    %6.4f±%6.4f   %6.4f±%6.4f   %6.4f±%6.4f \n", means[0][0], vars[0][0], means[0][1], vars[0][1], means[0][2], vars[0][2]);
		System.out.printf(Locale.ENGLISH, "Poisson     %6.4f±%6.4f   %6.4f±%6.4f   %6.4f±%6.4f \n", means[1][0], vars[1][0], means[1][1], vars[1][1], means[1][2], vars[1][2]);
		System.out.printf(Locale.ENGLISH, "Binomial    %6.4f±%6.4f   %6.4f±%6.4f   %6.4f±%6.4f \n", means[2][0], vars[2][0], means[2][1], vars[2][1], means[2][2], vars[2][2]);
	}
}
