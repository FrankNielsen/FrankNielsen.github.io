package Tutorials;

import jMEF.MixtureModel;

import java.awt.image.BufferedImage;

import Tools.Image;

public class Tutorial5{



	
	/**
	 * Main function.
	 * @param args
	 */
	public static void main(String[] args) {
		
		// Display
		String title = "";
		title += "+----------------------------------------+\n";
		title += "| Statistical images from mixture models |\n";
		title += "+----------------------------------------+\n";
		System.out.print(title);

		// Variables
		int n = 32;
		
		// Image/texture information
		String input_folder  = "D:/Work/Programming/Input/";
		String output_folder = "output/";
		String image_name    = "Lena";
		String image_path    = input_folder + image_name + ".png";
		String mixture_path  = String.format("%s%s_5D_%03d.mix", input_folder, image_name, n); 
		
		// Read image and generate initial mixture model
		System.out.print("Read image and generate/load the mixture 5D : ");
		BufferedImage image = Image.readImage(image_path);
		MixtureModel  f     = Image.loadMixtureModel(mixture_path, image, n);
		System.out.println("ok");
		
		// Creates and save the statistical image
		System.out.print("Create the statistical image                : ");
		BufferedImage stat = Image.createImageFromMixtureModel(image.getWidth(), image.getHeight(), f);
		Image.writeImage(stat, String.format("%sS_%s_dist_%03d.png", output_folder, image_name, n));
		System.out.println("ok");

		// Creates and save the ellipse image
		System.out.print("Create the ellipse image                    : ");
		BufferedImage ell = Image.createEllipseImage(image.getWidth(), image.getHeight(), f, 2);
		Image.writeImage(ell, String.format("%sS_%s_ell_%03d.png", output_folder, image_name, n));
		System.out.println("ok");
		
	}
	
}
