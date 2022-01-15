package Tutorials;

import jMEF.*;
import jMEF.BregmanHierarchicalClustering.LINKAGE_CRITERION;
import jMEF.Clustering.CLUSTERING_TYPE;

import java.awt.image.BufferedImage;
import java.util.Vector;

import Tools.Image;
import Tools.KMeans;

public class Tutorial4 {
	
	
	/**
	 * Load a mixture model from a file. If the mixture doesn't exist, the function create
	 * a mixture of multivariate Gaussians from the pixels of the image, and save this mixture.
	 * @param   path   file-path of the mixture model
	 * @param   image  input image
	 * @param   n      number of components in the mixture model
	 * @return         a mixture of Gaussian of n components computed from the input image
	 */
	private static MixtureModel loadMixtureModel(String path, BufferedImage image, int n){
		MixtureModel mm = MixtureModel.load(path);
		if (mm==null){
			PVector[]         px       = Image.convertColorImageToPointSet3D(image);
			Vector<PVector>[] clusters = KMeans.run(px, n);
			mm = BregmanSoftClustering.initialize(clusters, new MultivariateGaussian());
			mm = BregmanSoftClustering.run(px, mm);
			MixtureModel.save(mm, path);
		}
		return mm;
	}

	
	/**
	 * Main function.
	 * @param args
	 */
	public static void main(String[] args) {
		
		// Display
		String title = "";
		title += "+----------------------------------------------------+\n";
		title += "| Hierarchical mixture models and image segmentation |\n";
		title += "+----------------------------------------------------+\n";
		System.out.print(title);
		
		// Variables
		int n = 32;
		int m = 8;
		
		// Image/texture information
		String input_folder  = "C:/Input/";
		String output_folder = "output/";
		String image_name    = "Baboon";
		String image_path    = input_folder + image_name + ".png";
		String mixture_path  = String.format("%s%s_%03d.mix", input_folder, image_name, n); 
		
		// Read image and generate initial mixture model
		BufferedImage image = Image.readImage(image_path);
		MixtureModel  mm1   = loadMixtureModel(mixture_path, image, n);
		
		// Initial segmentation from MoG
		BufferedImage seg1 = Image.segmentColorImageFromMOG(image, mm1);
		Image.writeImage(seg1, String.format("%s%s_Hierarchical_%03d.png", output_folder, image_name, n));

		// Build hierarchical mixture model
		HierarchicalMixtureModel hmm = BregmanHierarchicalClustering.build(mm1, CLUSTERING_TYPE.SYMMETRIC, LINKAGE_CRITERION.MAXIMUM_DISTANCE);
		
		// Initial segmentation from simplified MoG
		MixtureModel  mm2  = hmm.getResolution(m);
		//MixtureModel  mm2  = hmm.getOptimalMixtureModel(0.5);
		BufferedImage seg2 = Image.segmentColorImageFromMOG(image, mm2);
		Image.writeImage(seg2, String.format("%s%s_Hierarchical_%03d.png", output_folder, image_name, m));

		System.out.println("Done!");
	}
}
