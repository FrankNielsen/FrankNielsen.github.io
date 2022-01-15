package Tutorials;

import java.util.Vector;

import Tools.ExpectationMaximization1D;
import Tools.KMeans;
import jMEF.*;

public class Tutorial2 {

	public static void main(String[] args) {

		// Display
		String title = "";
		title += "+----------------------------------------+\n";
		title += "| Bregman soft clustering & classical EM |\n";
		title += "+----------------------------------------+\n";
		System.out.print(title);

		// Variables
		int n = 3;
		int m = 1000;
		
		// Initial mixture model
		MixtureModel mm = new MixtureModel(n);
		mm.EF = new UnivariateGaussian();
		for (int i=0; i<n; i++){
			PVector param  = new PVector(2);
			param.array[0] = 10 * (i+1);
			param.array[1] = 2  * (i+1);
			mm.param[i]    = param;
			mm.weight[i]   = i+1;
		}
		mm.normalizeWeights();
		System.out.println("Initial mixure model \n" + mm + "\n");
		
		// Draw points from initial mixture model and compute the n clusters
		PVector[]         points   = mm.drawRandomPoints(m);
		Vector<PVector>[] clusters = KMeans.run(points, n);
		
		// Classical EM
		MixtureModel mmc;
		mmc = ExpectationMaximization1D.initialize(clusters);
		mmc = ExpectationMaximization1D.run(points, mmc);
		System.out.println("Mixure model estimated using classical EM \n" + mmc + "\n");
		
		// Bregman soft clustering
		MixtureModel mmef;
		mmef = BregmanSoftClustering.initialize(clusters, new UnivariateGaussian());
		mmef = BregmanSoftClustering.run(points, mmef);
		System.out.println("Mixure model estimated using Bregman soft clustering \n" + mmef + "\n");
		
	}
}
