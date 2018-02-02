import java.io.*;
import java.util.*;

public class PPM
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
            out.writeBytes("# INF555 Ecole Polytechnique\n");
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
