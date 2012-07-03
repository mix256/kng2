
import helpers.Characters;
import helpers.Room;
import helpers.Tiles;

import java.awt.image.BufferedImage;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;

import javax.imageio.ImageIO;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

/**
 * 
 * Takes pictures of (320*x) x 200 in size and
 * converts them into characters and tiles.
 * - Character0 is always $d800
 * - Tile0 is always Character0's
 * - Character1 is always background color
 * - Character2-3 are mainbullets
 * 
 * @author Mikael Tillander
 *
 */
public class Png2CharsTask extends Task
{
	private String inputFile = null;
	
	private String outputFile = null;
	
	private ArrayList<Object> rooms = new ArrayList<Object>();
	
	private Characters chars = new Characters();
	private Tiles tiles = new Tiles();

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
		
		chars.print();
		tiles.print();
		printRooms();
		
		FileOutputStream fos;
		/* 
		 * BKG:
		 * 1   byte		- Number of rooms
		 * [36  bytes	- palette for room 0
		 * 1   byte		- Room size in large tiles
		 * x   bytes	- Large tile data]
		 *
		 * [20*x bytes	- Small Tile data]
		 *
		 * [5*x bytes	- Large Tile data]
		 * 
		 * CHARS:
		 * 256*8 bytes	- Character data
		 */
		try {
			fos = new FileOutputStream(outputFile +  "bkg");
			DataOutputStream dos = new DataOutputStream(fos);
			saveRooms(dos);
			dos.close();

			fos = new FileOutputStream(outputFile +  "stil");
			dos = new DataOutputStream(fos);
			tiles.writeSmall(dos);
			dos.close();

			fos = new FileOutputStream(outputFile +  "ltil");
			dos = new DataOutputStream(fos);
			tiles.writeLarge(dos);
			dos.close();

			fos = new FileOutputStream(outputFile + "chars");
			dos = new DataOutputStream(fos);
			chars.write(dos);
			dos.close();
			
		} catch (Exception e) {
			System.out.println("Write error: ");
			e.printStackTrace();
		}
	}
	
	public void convert()
	{
		Iterator<Object> i = rooms.iterator();
		while(i.hasNext()){
			Room room = (Room)i.next();
			room.convert(chars, tiles);
		}
	}
	
	public void printRooms(){
		int a = 0;
		Iterator<Object> i = rooms.iterator();
		while(i.hasNext()){
			Room room = (Room)i.next();
			System.out.println("Room: " + a);
			room.print();
			a++;
		}
	}

	public void saveRooms(DataOutputStream dos) throws IOException{
		int a = 0;
		dos.write(rooms.size()); // len
		Iterator<Object> i = rooms.iterator();
		while(i.hasNext()){
			Room room = (Room)i.next();
			room.save(dos);
		}
	}	
	
	private void loadFiles()
	{
		int i=0;
		boolean done = false;
		while(!done){
			Room room = new Room();
			try
			{
				room.loadImage(inputFile, i);
				room.loadColorDefinitions(inputFile, i);
				rooms.add(room);
				i++;
			}catch (IOException e){
				done = true;
			}
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