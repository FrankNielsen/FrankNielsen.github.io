package Tutorials;

import jMEF.*;
import jMEF.Clustering.CLUSTERING_TYPE;

import java.awt.image.BufferedImage;
import java.util.Vector;

import Tools.Image;
import Tools.KMeans;

public class Tutorial3 {
	
	
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
		title += "+-----------------------------------------------+\n";
		title += "| Mixture simplification and image segmentation |\n";
		title += "+-----------------------------------------------+\n";
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
		
		// Read image and generate initial mixture model mm1
		BufferedImage image = Image.readImage(image_path);
		MixtureModel  mm1   = loadMixtureModel(mixture_path, image, n);
		
		// Compute the image segmentation based on the mixture mm1
		BufferedImage seg1 = Image.segmentColorImageFromMOG(image, mm1);
		Image.writeImage(seg1, String.format("%s%s_%03d.png", output_folder, image_name, n));

		// Simplify mm1 in a mixture mm2 of m components and compute the image segmentation based on mm2
		MixtureModel  mm2  = BregmanHardClustering.simplify(mm1, m, CLUSTERING_TYPE.LEFT_SIDED);
		BufferedImage seg2 = Image.segmentColorImageFromMOG(image, mm2);
		Image.writeImage(seg2, String.format("%s%s_%03d.png", output_folder, image_name, m));
		
		System.out.println("Done!");
	}

}
