
import java.awt.image.BufferedImage;
import java.io.BufferedOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;

import javax.imageio.ImageIO;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

public class MemMoverTask extends Task
{
	String row1, row2;
	int r1i = -1;
	int r2i = -1;
	String outputFile;
	int numberOfRows = -1;
	int adder = -1;
	
	public void setOutputFile(String filename)
	{
		outputFile = filename;
	}
	
	public void setRow1(String r1)
	{
		row1 = r1;
	}

	public void setRow2(String r2)
	{
		row2 = r2;
	}	

	public void setRow1Init(String r1)
	{
		r1i = Integer.parseInt(r1);
	}

	public void setRow2Init(String r2)
	{
		r2i = Integer.parseInt(r2);
	}

	public void setNumberOfRows(String r)
	{
		numberOfRows = Integer.parseInt(r);
	}		

	public void setAdder(String r)
	{
		adder = Integer.parseInt(r);
	}	
	
	/**
	 * Execute.
	 * 
	 * @throws BuildException the build exception
	 */
	public void execute() throws BuildException
	{
		try
		{
			validate();
			convert();
		}
		catch(Exception e)
		{
			throw new BuildException(e.toString());
		}
	}
	
	private void convert() throws Exception
	{
		FileOutputStream fl= new FileOutputStream(outputFile);
		DataOutputStream dos = new DataOutputStream(fl);

		int a = 0;
		log("Creating");
		for(int j = 0; j < numberOfRows; j++)
		{
			String r1 = "\t" + row1 + " + " + r1i + " + " + a + "\n";
			String r2 = "\t" + row2 + " + " + r2i + " + " + a + "\n";
			dos.writeBytes(r1);
			dos.writeBytes(r2);
			a += adder;
		}
		
		dos.writeBytes("\trts\n");
		
	}

	/**
	 * 
	 * @throws BuildException
	 */
	private void validate() throws BuildException
	{
		if(outputFile == null)
			throw new BuildException("Attribute outputFile has not been set");
		if(row1 == null)
			throw new BuildException("Attribute row1 has not been set");
		if(row2 == null)
			throw new BuildException("Attribute row2 has not been set");
		if(r1i == -1)
			throw new BuildException("Attribute row1init has not been set");
		if(r2i == -1)
			throw new BuildException("Attribute row2init has not been set");
		if(adder == -1)
			throw new BuildException("Attribute adder has not been set");
		if(numberOfRows == -1)
			throw new BuildException("Attribute numberofrows has not been set");
	}
}