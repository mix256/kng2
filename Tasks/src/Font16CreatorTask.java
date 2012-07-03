import helpers.Palette;

import java.awt.image.BufferedImage;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import javax.imageio.ImageIO;

import org.apache.tools.ant.BuildException;


public class Font16CreatorTask {
	
	private String inputFile = null;
	
	private String outputFile = null;

	BufferedImage png;
	
	int[] data;
	
	/**
	 * Sets the input file.
	 * 
	 * @param file the file
	 */
	public void setInputFile(String filename)
	{
		inputFile = filename;
	}	

	/**
	 * Sets the output file.
	 * 
	 * @param file the file
	 */
	public void setOutputFile(String filename)
	{
		outputFile = filename;
	}
	
	/**
	 * Execute.
	 * 
	 * @throws BuildException the build exception
	 */
	public void execute() throws BuildException
	{
		try{
			validate();
			loadFiles();
			convert();
			save();
		}catch(Exception e){
			throw new BuildException(e.toString());
		}
	}

	public void save(){
		
		FileOutputStream fos;
		
		try {
			fos = new FileOutputStream(outputFile);
			DataOutputStream dos = new DataOutputStream(fos);
			for(int i=0; i < data.length; i++)
			{
				dos.write(data[i]);
			}
			dos.close();
			
		} catch (Exception e) {
			System.out.println("Write error: ");
			e.printStackTrace();
		}
	}
	
	public void convert()
	{
		System.out.println("width: " + png.getWidth());
		System.out.println("height: " + png.getHeight());
		int numberOfChars = (png.getWidth() / 16);
		data = new int[32 * numberOfChars];
		int j = 0;
		for(int x = 0; x < png.getWidth(); x += 8)
		{
			for(int y = 0; y < png.getHeight(); y++)
			{
				int dat = 0;
				int a = 6;
				for(int i = 0; i < 8; i += 2)
				{
					int col = (png.getRGB(x + i, y)) & 0x0ffffff;
					dat |= (getBitPair(col) << a);
					a -= 2;
				}
				data[j] = dat;
				System.out.println("" + data[j]);
				j++;
			}			
		}
	}
	
	public int getBitPair(int value)
	{
		for(int i = 0; i < 16; i++)
		{
			if(Palette.PALETTE[i] == value)
			{	
				if(i == 0)
					return 3;
				if(i == 11)
					return 1;
				if(i == 15)
					return 2;
				return 0;
			}
		}
		return 0;
	}
	
	private void loadFiles()
	{
		try
		{
			System.out.println("loading" + inputFile);
			png = ImageIO.read(new File(inputFile));		
		}catch (Exception e){
			System.out.println("load error");
		}
	}

	/**
	 * 
	 * @throws BuildException
	 */
	private void validate() throws BuildException
	{
		if(inputFile == null)
			throw new BuildException("Attribute inputFile has not been set");
		if(outputFile == null)
			throw new BuildException("Attribute outputFile has not been set");
	}	
}
