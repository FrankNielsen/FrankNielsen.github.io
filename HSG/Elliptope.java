class Elliptope
{
	
	static void elliptope()
{
	int nb=0;
	double steps = 51;
       double maxval = 1;
        double valstep = 2.0 / steps;
        for (double x = -1; x <= maxval; x+= valstep) {
            for (double y = -1; y <= maxval; y += valstep) {
                for (double z = -1; z <= maxval; z += valstep) {
                    double det = 1 + 2*x*y*z - x*x - y*y - z*z;
                    if (det >= 0 && det <= 0.05) {
                        System.out.println(x+"\t"+y+"\t"+z);nb++;
                        //data.addRow([x,y,z]);
                    }
                }
            }
        }
	System.out.println(nb);
	}
	
		public static void main(String [] a)
	{
		elliptope();
		}
		
		}
		